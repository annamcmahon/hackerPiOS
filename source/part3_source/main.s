.section .init
.globl _start
_start:

/*
* Branch to the actual main code.
*/
b main

/*
* tells the assembler to put this code with the rest.
*/
.section .text

/*
* main is what we shall call our main operating system method.
*/
main:

/*
* Set the stack point to 0x8000.
*/
mov sp,#0x8000

/*
* Use our new SetGpioFunction function to set the function of GPIO port 47 (OK
* LED) to 001 (binary)
*/

pinNum .req r0
pinFunc .req r1
mov pinNum,#47
mov pinFunc,#1
bl SetGpioFunction
.unreq pinNum
.unreq pinFunc

/*
* Use our new SetGpio function to set GPIO 47 to high, causing the LED to turn 
* on.
*/
loop$:
pinNum .req r0
pinVal .req r1
mov pinNum,#47
mov pinVal,#1
bl SetGpio
.unreq pinNum
.unreq pinVal

/*
* Delay
*/
decr .req r0
mov decr,#0x1F800
wait1$: 
	sub decr,#1
	teq decr,#0
	bne wait1$
.unreq decr

/*
* Use our new SetGpio function to set GPIO 47 to low, causing the LED to turn
* on.
*/
pinNum .req r0
pinVal .req r1
mov pinNum,#47
mov pinVal,#0
bl SetGpio
.unreq pinNum
.unreq pinVal

/*
* Delay
*/
decr .req r0
mov decr,#0x1F800
wait2$:
	sub decr,#1
	teq decr,#0
	bne wait2$
.unreq decr

/*
* loop
*/
b loop$
