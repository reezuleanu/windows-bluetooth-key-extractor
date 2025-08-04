function Get-BluetoothLinkKey {
    $baseRegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters\Keys"

    # Get adapters
    try {
        $adapters = Get-ChildItem $baseRegPath -ErrorAction Stop
    } catch {
        Write-Error "❌ Failed to access Bluetooth keys registry. Run as SYSTEM."
        return
    }

    if ($adapters.Count -eq 0) {
        Write-Host "No Bluetooth adapters found." -ForegroundColor Yellow
        return
    }

    Write-Host "Available Bluetooth Adapters:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $adapters.Count; $i++) {
        Write-Host "[$i] $($adapters[$i].PSChildName)"
    }

    $adapterIndex = Read-Host "Enter adapter number"
    if ($adapterIndex -notmatch '^\d+$' -or $adapterIndex -ge $adapters.Count) {
        Write-Error "Invalid adapter selection."
        return
    }
    $adapter = $adapters[$adapterIndex]

    # Read properties (device MAC addresses are property names)
    try {
        $props = Get-ItemProperty -Path "$baseRegPath\$($adapter.PSChildName)"
    } catch {
        Write-Error "❌ Can't read adapter registry key. Run as SYSTEM?"
        return
    }

    # Prepare list of device keys (exclude known non-device props)
    $ignoreProps = @("PSPath", "PSParentPath", "PSChildName", "PSDrive", "PSProvider", "MasterIRK")

    $deviceProps = $props.PSObject.Properties | Where-Object { $ignoreProps -notcontains $_.Name }

    if ($deviceProps.Count -eq 0) {
        Write-Host "No paired devices found for this adapter." -ForegroundColor Yellow
        return
    }

    # Get friendly names for devices via PnP to display
    Write-Host "`nPaired Devices:" -ForegroundColor Cyan
    $deviceList = @()
    $i = 0

    # Get PnP Bluetooth devices for name lookup
    $pnpDevices = Get-PnpDevice -Class Bluetooth | Where-Object { $_.Status -eq 'OK' }

    foreach ($deviceProp in $deviceProps) {
        # MAC from registry property name (e.g., 20af1b200c5d)
        $mac = $deviceProp.Name.ToLower()

        # Try to find friendly name from PnP list by matching MAC in InstanceId
        $friendlyName = $null
        foreach ($pnpDev in $pnpDevices) {
            if ($pnpDev.InstanceId -match "DEV_([0-9A-F]+)" -and $mac -eq $matches[1].ToLower()) {
                $friendlyName = $pnpDev.FriendlyName
                break
            }
        }

        if (-not $friendlyName) {
            $friendlyName = "(Unknown Name)"
        }

        Write-Host "[$i] $friendlyName ($mac)"
        $deviceList += [PSCustomObject]@{
            Index = $i
            MAC = $mac
            FriendlyName = $friendlyName
            KeyBytes = $deviceProp.Value
        }
        $i++
    }

    $deviceIndex = Read-Host "Enter device number to extract"
    if ($deviceIndex -notmatch '^\d+$' -or $deviceIndex -ge $deviceList.Count) {
        Write-Error "Invalid device selection."
        return
    }

    $device = $deviceList[$deviceIndex]
    $hexKey = ($device.KeyBytes | ForEach-Object { '{0:X2}' -f $_ }) -join ''

    # Prepare output text
    $output = @"
Device Friendly Name: $($device.FriendlyName)
Device MAC: $($device.MAC)
Link Key (HEX): $hexKey
"@

    # Determine the output directory - one folder up from script
    $scriptPath = $MyInvocation.MyCommand.Path
    if ([string]::IsNullOrEmpty($scriptPath)) {
        Write-Host "Script path is null or empty, using current directory." -ForegroundColor Yellow
        $scriptDir = Get-Location
    } else {
        $scriptDir = Split-Path -Path $scriptPath -Parent
    }
    $parentDir = Split-Path -Path $scriptDir -Parent

    $filename = "bluetooth_link_key_$($device.MAC).txt"
    $filepath = Join-Path $parentDir $filename

    Write-Host "Script path: $scriptPath"
    Write-Host "Script directory: $scriptDir"
    Write-Host "Parent directory (output folder): $parentDir"
    Write-Host "Full output file path: $filepath"

    Set-Content -Path $filepath -Value $output -Encoding UTF8

    Write-Host "`n✅ Link key saved to: $filepath" -ForegroundColor Green
}

Get-BluetoothLinkKey
Write-Host "`nPress any key to exit..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
