.globl GetGpioAddress
GetGpioAddress:
	ldr r0,=0x3F200000
	/*pc holds address of next instruction, lr is code to go back to*/
	mov pc,lr

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
.globl SetGpioFunction
SetGpioFunction:
	/*check the inputs*/
	cmp r0,#53
	/* compares only if r0<=53, if not, execute movhi*/
	cmpls r1,#7
	/* movhi only happens if r1 <= 7 or r0<=53 */
	movhi pc,lr
	/* save the previous lr to return to*/
	push {lr}
	mov r2,r0
	/* calls function, sets lr to next instructions address*/
	bl GetGpioAddress
	/*r0 contains the GPIO address, r1 contains the function code and r2 contains the GPIO pin number*/
	/* want r0 to contain the address of pin function settings, r2 will contain # 0-9*/
	functionLoop$:
		cmp r2,#9
		subhi r2,#10
		addhi r0,#4
		bhi functionLoop$
	add r2, r2,lsl #1 /* tricky *3, multiply by 3 to get the bits associated w pin #*/
	lsl r1,r2 /* r1 contains a function code, like 001. we shift the function code value by associated bits to set the bits that correspond to our pin number*/
	str r1,[r0] /*store computed function value at the address in GPIO controller*/
	pop {pc}
# TODO, make pins in same block of 10 not set to 0

.globl SetGpio
SetGpio:
	pinNum .req r0
	pinVal .req r1
	cmp pinNum,#53
	movhi pc,lr
	push {lr}
	mov r2,pinNum
	.unreq pinNum
	pinNum .req r2
	bl GetGpioAddress
	gpioAddr .req r0
	pinBank .req r3
	/* need to add 4 to gpioaddr if in pin bank 1*/
	/* divide by 32 to get which pin bank the pin is in (0 or 1)*/
	lsr pinBank,pinNum,#5
	/* multiply by 4 */
	lsl pinBank,#2
	add gpioAddr,pinBank
	.unreq pinBank

	/* get the pin number, relative to pinBank*/
	/* ie 47, you want pinNum to be 15, Add w 11111 to get remainder when divide by 32*/
	and pinNum,#31
	setBit .req r3
	mov setBit,#1
	lsl setBit,pinNum
	.unreq pinNum

	/* turn the pin on or off*/
	teq pinVal,#0
	.unreq pinVal
	streq setBit,[gpioAddr,#28]
	strne setBit,[gpioAddr,#40]
	.unreq setBit
	.unreq gpioAddr
	pop {pc}


