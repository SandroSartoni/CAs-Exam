In order to execute 64-bits source code, a 64-bits OS is needed.
The official OS for Raspberry is Raspbian, a 32-bits distribution, based on Debian, made
specifically for ARM chips. Unfortunately, no official support is still present for 64-bits
OS, even though there're some various releases online. The SD card used with
Raspberry is a Class 10, 32 GB Kingston card, that showed to work flawlessly
with Raspbian. Various 64-bits OSs were tried, such as Arch ARM or openSUSE, and
all of them showed some random errors, not due to other possible causes, such
as the PSU for example. The only one that worked without any particular problem
is pi64, that can be obtained at this link: https://github.com/bamarni/pi64 .
Installing this OS is fairly easy: if working on a Windows environment, it's
necessary to format first the SD card, using for example a program called SD
Card Formatter, available at the link: https://www.sdcard.org/downloads/formatter_4/ .
Once formatted, it's possible to load the image using Etcher, available at the link
https://etcher.io/ , that should recognize automatically the SD card.
If working on a Linux environment, an exhaustive documentation can be found at
https://www.raspberrypi.org/documentation/installation/installing-images/linux.md , provided
that whenever 2017-11-29-raspbian-stretch.img is found, it has to be changed with the
actual name of the image file.
At this point, it's necessary to go through some steps to have everything working. 
The first thing to do is to update the OS, but since there're some issues related to
the internet connection, it's best to modify the file wpa_supplicant.conf by:
`
#sudo leafpad /etc/wpa_supplicant/wpa_supplicant.conf
`
and once there, type: 
```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
#update_config=1
network={
ssid="wifi_name"
psk="wifi_password"
priority=5
}
```
Eventually connecting via ethernet should solve the problem.
The next thing is to update the kernel, by typing `sudo pi64-update` and change the
keyboard layout (if necessary).
To write the source file by terminal, just type the name of the text editor followed by the name
of the source code (for example vim filename.s).
In order to be able to compile and run the 32-bits code, it's necessary to enable multiarch and installing
required libraries:
```
sudo dpkg --add-architecture armhf
sudo apt-get update
sudo apt-get install libc6:armhf
```
To install the compiler:
```
$ sudo apt-get install libc6-armel-cross libc6-dev-armel-cross
$ sudo apt-get install binutils-arm-linux-gnueabi
$ sudo apt-get install libncurses5-dev
$ sudo apt-get install gcc-arm-linux-gnueabi
$ sudo apt-get install g++-arm-linux-gnueabi
```
To generate the executable file, it's necessary to type `arm-linux-gnueabi-gcc filename.s -o filename`.
If, by typing `./filename` there're still problems, type `file ./filename`
and, if there's written `interpreter /lib/ld-linux.so.3` then it's necessary to write
`ln -s /lib/ld-linux-armhf.so.3 /lib/ld-linux.so.3`. Everything should work now.
Regarding 64-bits files, to generate the executable it's necessary to type into the terminal:
```
as -g -o filename.o filname.s
gcc -o filename filename.o
```
provided that we currently are in the folder containing filename.s source code. Notice that 
`-g` is used in order to be able to debug the executable file i.e. using GDB.
To install GDB it's sufficient to type `sudo apt-get install gdb`.
