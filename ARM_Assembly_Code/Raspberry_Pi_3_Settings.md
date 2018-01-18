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
Once everything has been set, it's possible to execute directly 64-bits files, by
typing into the terminal the commands:

```
as -g -o filename.o filname.s
gcc -o filename filename.o
```

provided that we currently are in the folder containing filename.s source code. Notice that 
`-g` is used in order to be able to debug the executable file i.e. using GDB.
In order to execute 32-bits programs instead, it's necessary to enable multiarch and install
the required libraries. Every information can be found at the OS link.
Another possible way is to follow the instructions at the link https://www.acmesystems.it/arm9_toolchain .
Regarding the latter link, the instruction `arm-linux-gnueabi-gcc filename.s -o filename` has been
tested with success.
Finally, simply type `./filename` in order to start executing the program.
