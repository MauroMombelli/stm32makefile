#  stm32 makefile
This project want to provide a minimal but powerfult makefile to build stm32 project, following the KISS concept, but without hiding or preventing away advanced concept.  
  
It is an arbitrary equilibrium, baded on different concept; basically repetitive and common operation are standardized, but user still have to deal with some basic configuration (makefile and vector table) before be ready to go. On the other hand, "hardcore" configuration can be easily achived since the whole buid process follow the standard flow, without hiding any passsage.  
  
As example, by default the project is set up to run on a STM32f407VGT6.

## CMSIS and ST's Standard Library
Despite some horror story about the quality of such library ST's Standard Library, I believe is the best out there since based on a industry standard such CMSIS, and generally widly used.  
There are different HAL, but they are or based on those library, or ST specific (vendor lock risk), or even worse complexity/interface (Arduino's core).

## Easy to use
The project is by default setup for stm32f4xx chips: if you are using such chip, just add your files in SRC, modify/delete the main.c example and just "make" it.  
Source file, even in subfolder, will be automatically found and compiled.  
Include path are by default the CMSIS folder, the Stadard Library folder, and the src folder.  
CPP is supported out of the box (RSSI enabled, but NOT exceptions)

## Easy to personalize
The makefile is kept simple, less than a hundred lines, with clear explanation of what a "normal" user should modify to support another chip; a skilled user will understand all he need at the first glance.

## Vector table
Vector table is something you will have to deal as soon as you start to use some interrupt, and need to be personalized for each chip. For this reason I use a nice C array, in its own file, so you can mess with it without risk of messing with other stuff.

## Startup file in C
We spoke about using standardized stuff and KISS princlple, and a custom made startup script does not really feel part of it but here my reasoning are the same:  
startup script are quite standard and very similar to each other: clear the BBS, init the C++ constructor, init the hardware, lauch the main.  
Normally you wont need to modify it or know how it works; and even when you require some advanced fature like using different RAM region or enabling some chip feature you are always asked to blindly add some define or decomment some code.  
Using a C startup I want to make clear and easy to understand the startup process even to newcomers.  
And you will still have access to assebly, just use objdump to dump the compiled object.

## Default Linker Script
Thespite the custom Startup file, the simbols used are the standard used by the CMSIS and ST Periferical Library (in case of discrepancy CMSIS is used).  
As Statup script can be so generic I don't expect any issue along different MCU, the opposite is true for liker script: the same chip can have different size of memory depending on the specific model choosen, and most of the time does not require any modification, so just copy paste the default one.