.section .init
.globl _start
_start:

b main

/*
* This command tells the assembler to put this code with the rest.
*/
.section .text

main:

/*
* Set the stack point to 0x8000.
*/
mov sp,#0x8000

/*
* Use our new SetGpioFunction function to set the function of GPIO port 47 (OK 
* LED) to 001
*/
mov r0,#47
mov r1,#1
bl SetGpioFunction

/* 
* Load in the pattern to flash and also store our position in the flash
* sequence.
*/
ptrn .req r4
ldr ptrn,=pattern
ldr ptrn,[ptrn]
seq .req r5
mov seq,#0

loop$:

/* 
* Use our new SetGpio function to set GPIO 47 base on the current bit in the 
* pattern causing the LED to turn on if the pattern contains 0, and off if it
* contains 1.
*/
mov r0,#47
mov r1,#1
lsl r1,seq
and r1,ptrn
bl SetGpio

/* 
* We wait for 0.25s using our wait method.
*/
ldr r0,=250000
bl Wait

/* 
* Loop, incrementing the sequence counter.
* When it reaches 32, its bit pattern becomes 100000, and so anding it with 
* 11111 causes it to return to 0, but has no effect on all patterns less than
* 32.
*/
add seq,#1
and seq,#0b11111
b loop$

/* 
* In the data section of the kernel image, store the pattern we wish to flash
* on the LED.
*/
.section .data
.align 2
pattern:
.int 0b11111111101010100010001000101010
