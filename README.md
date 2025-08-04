# Use case
If you dual boot Linux and Windows and use some Bluetooth device (a headset, a mouse, a keyboard, etc.) due to how Bluetooth pairing works, you would need to pair your devices each time you change the operating system you boot from, because each paired device has a secret key that differes across operating systems. In Linux it is quite straight forward to get/set this key for your devices, but if you use Windows, that's an entire different beast unfortunately, which is why I made this repo.

# How to use
Run `run.bat` as administrator, then select the device you want to get the key for. It will write it to a .txt file at a location shown in the console.

# NOTICE
Currently, it will output the key of the device under C:/WINDOWS, this is due to the fact that the script needs to run as SYSTEM, so the paths get confused. This is a WIP and will get fixed in the future.

# Future plans
I plan to also make an interactive bash script that will easily let you set these keys in Linux, to streamline the process even further.

# How to contribute
I don't know why you would want to, but just fork the repo, contribute what you want (pictures of watermelons are acceptable), then make a PR.
