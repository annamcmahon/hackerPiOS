/*
soc peripherals link:http://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/os/downloads/SoC-Peripherals.pdf

*/
/* 
* assembler instructions
*/
.section .init
.globl _start
_start:

/* 
* store the number 0x3F200000 into the register r0,
* 0x3F200000 is hexidecimal address for gpio region
*/
ldr r0,=0x3F200000

/*
* r1=1 << 21    Enable the output of the 47th GPIO pin, use GPIO pin 47 for OK/ACT
* Why 21? 24 bytes in the GPIO controller, which determine the settings of the GPIO pin. 
* The first 4 relate to the first 10 GPIO pins, the second 4 relate to the next 10 and so on. 
* There are 54 GPIO pins, so we need 6 sets of 4 bytes, which is 24 bytes in total. 
* Within each 4 byte section, every 3 bits relates to a particular GPIO pin. 
* Since we want the 47th GPIO pin, we need the fourth set of 4 bytes because we're dealing with pins 40-49
* we need the 7th set of 3 bits, which is where the number 21 (7x3)
* (we know we want 21-23 -bits controlling pin 47's function- to be 001 because this makes it an output)
* ^ see function select chart on page 94 of soc-peripherals 
*/
mov r1,#1
lsl r1,#21

/*
* Set the GPIO function select.
* This means we add 16 to the GPIO controller address (r0) and write the value in r1 to that location.
* 0x10 is 16, this is used because we need the fourth set of 4 bytes because we're dealing with pins 40-49
* sends message to GPIO controller
*/
str r1,[r0,#0x10]

/*
* construct another message for GPIO controller
*/

/*
* Set the 15th bit of r1. 15 comes from 47mod(32)
*/
mov r1,#1
lsl r1,#15 

/*
* Label the next line loop$ for the infinite looping
*/
loop$:

/* write to GPIO+44 to turn off, GPIO+32 to turn on
* Because there are 54 pins, there are two memory locations for each function
* GPSET0, GPCLR0, ..etc controlled pins 0-31, GPSET1 and GPCLR1 control GPIOs 32 to 54, 
* because we are interested in pin 47, we want to write our messages to these locations
* see page 90 of soc-peripherals
* Setting any bit in the "GPSETn" locations to 1 will turn that GPIO on. Bits set to 0 will have no effect.
* Setting any bit in the "GPCLRn" locations to 1 will turn that GPIO off. 
* Pin setting explained here: https://www.raspberrypi.org/forums/viewtopic.php?f=72&t=86370
*/
/*
* Set GPIO 47 to low, causing the LED to turn on.
* 0x20 = 32 
*/
str r1,[r0,#32] 

/* 
* delay by decrement the number 0x3F0000 to 0
*/
mov r2,#0x1F800
wait1$:
    sub r2,#1
    cmp r2,#0
    bne wait1$

/* 
* Set GPIO 47 to high, causing the LED to turn off.
* 0x2C = 44
*/
str r1,[r0,#44]

/*
* delay
*/
mov r2,#0x1F800
wait2$:
    sub r2,#1
    cmp r2,#0
    bne wait2$

/*
* Loop 
*/
b loop$
