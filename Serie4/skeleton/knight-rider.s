/*
-----------------------------------------------------------
 Series 4 - Raspberry Pi Programming Part 1 - Running Light
 
 Group members:
 --Our code is really dumb, we got it working with LSL and LSR, but ran into some bugs lateron, so we decided
 to do it the dumb way. The programme still works :) Think outside the box, or like a box
 Manuel Flückiger; Deepak Parapuckal; Nicolas Willimann
 
 Individualised code by:
 Manuel Flückiger
 
 Exercise Version:
 1

 Notes:
 We provide hints and guidance in the comments below and
 strongly encourage you to follow the skeleton.
 However, you are free to change the code as you like.
 
-----------------------------------------------------------
*/

.global main
.func main

main:
	// This will setup the wiringPi library.
	// In case something goes wrong, we exit the program
	BL	wiringPiSetupGpio		
	CMP	R0, #-1			
	BEQ	exit


configurePins:
	// Set the data pin to 'output' mode
	LDR	R0, .DATA_PIN
	LDR	R1, .OUTPUT
	BL	pinMode

	// Set the latch pin to 'output' mode
	/* to be implemented by student */
	LDR R0, .LATCH_PIN
	LDR R1, .OUTPUT
	BL pinMode


	// Set the clock pin to 'output' mode
	/* to be implemented by student */
	LDR R0, .CLOCK_PIN
	LDR R1, .OUTPUT
	BL pinMode

	// Set the pins of BUTTON 1 and BUTTON 2 to 'input' mode 
	/* to be implemented by student */
	LDR R0, .BUTTON1_PIN
	LDR R1, .INPUT
	BL pinMode

	LDR R0, .BUTTON2_PIN
	LDR R1, .INPUT
	BL pinMode

	LDR	R0, .BUTTON1_PIN
	LDR	R1, .PUD_UP
	BL	pullUpDnControl

	LDR	R0, .BUTTON2_PIN
	LDR	R1, .PUD_UP
	BL	pullUpDnControl

start:

	/* 
	Implement the main logic for the running light here and in the loop below.
	Depending on your implementation, you will probably need to initialise
	- a register to hold the state of the LED bar
	- a register to save the time delay for the LED
	- registers to save the state of the two buttons
	- a register for a counter variable
	- and/or other (temporary) registers as you wish.
	*/
	MOV R4,#0b00000001 //LED Bar (1-8)
	MOV R5,#500 //delay
	MOV R6,#0 //state of buttons (0-3)
	MOV R8,#0 //counter (0-1)

knightRiderLoop:
	/* 
	Implement this loop to make the light move.
	As described in the appendix of the exercise sheet, 
	you can use the shiftOut subroutine to send serial data.
	To do so
	1. Set the latch pin to low
	2. Send the data with shiftOut
	3. Set the latch pin to high
	*/
	first_step:
		MOV R4,#0b00000001
		// Set latch pin low (read serial data)
		/* to be implemented by student */
		LDR R0, .LATCH_PIN
		LDR R1, .LOW
		BL digitalWrite

		// Send serial data (shiftOut)
		/* to be implemented by student */
		LDR R0, .DATA_PIN
		LDR R1, .CLOCK_PIN
		LDR R2, .MSBFIRST //most for us is the correct one
		MOV R3, R4 //which led should light up
		BL shiftOut
		// Set latch pin high (write serial data to parallel output)
		/* to be implemented by student */
		LDR R0, .LATCH_PIN 
		LDR R1, .HIGH
		BL digitalWrite
	
	
		// Detect button presses and increase/decrease the delay
		// Use the 'waitForButton' subroutine for each button
		/* to be implemented by student */

		//up button
		LDR R0, .BUTTON1_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		CMP R0, #1
		BEQ increase_speed

		//down button
		LDR R0, .BUTTON2_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		CMP R0, #1
		BEQ decrease_speed


		// Wait delay milliseconds
		MOV	R0, R5
		BL 	delay

	/* Other logic goes here, like updating variables, branching to the loop label, etc. */
	/* to be implemented by student */
	//as stated on line 6 & 7, this part is coded really dumb (hardcoded). We did do it with LSL and LSR at first
	//ran into some trouble, tried fixing it for 3h and then wrote this in 20min. It works but ugly af
	//instead of #0b00... we could've of course used some register to store the value in and instead of MOV
	//used LSL and LSR where needed, but if we code it like that, there's really no point in doing it the 
	//proper way other than to show you that we can do it, so I did it with the first example (line 168 & 371)
	//up button
		LDR R0, .BUTTON1_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ increase_speed
		MOV R5, R0

		//down button
		LDR R0, .BUTTON2_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ decrease_speed
		MOV R5, R0
	//repeat 14 times...
	second_step:
		LSL R4, R4, #1
		LDR R0, .LATCH_PIN
		LDR R1, .LOW
		BL digitalWrite
		LDR R0, .DATA_PIN
		LDR R1, .CLOCK_PIN
		LDR R2, .MSBFIRST
		MOV R3, R4 
		BL shiftOut
		LDR R0, .LATCH_PIN 
		LDR R1, .HIGH
		BL digitalWrite
		MOV	R0, R5
		BL 	delay
		//up button
		LDR R0, .BUTTON1_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ increase_speed
		MOV R5, R0

		//down button
		LDR R0, .BUTTON2_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ decrease_speed
		MOV R5, R0
	third_step:
		MOV R4,#0b00000100
		LDR R0, .LATCH_PIN
		LDR R1, .LOW
		BL digitalWrite
		LDR R0, .DATA_PIN
		LDR R1, .CLOCK_PIN
		LDR R2, .MSBFIRST
		MOV R3, R4 
		BL shiftOut
		LDR R0, .LATCH_PIN 
		LDR R1, .HIGH
		BL digitalWrite
		MOV	R0, R5
		BL 	delay
		//up button
		LDR R0, .BUTTON1_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ increase_speed
		MOV R5, R0

		//down button
		LDR R0, .BUTTON2_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ decrease_speed
		MOV R5, R0

	fourth_step:
		MOV R4,#0b00001000
		LDR R0, .LATCH_PIN
		LDR R1, .LOW
		BL digitalWrite
		LDR R0, .DATA_PIN
		LDR R1, .CLOCK_PIN
		LDR R2, .MSBFIRST
		MOV R3, R4 
		BL shiftOut
		LDR R0, .LATCH_PIN 
		LDR R1, .HIGH
		BL digitalWrite
		MOV	R0, R5
		BL 	delay
		//up button
		LDR R0, .BUTTON1_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ increase_speed
		MOV R5, R0

		//down button
		LDR R0, .BUTTON2_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ decrease_speed
		MOV R5, R0
	fifth_step:
		MOV R4,#0b00010000
		LDR R0, .LATCH_PIN
		LDR R1, .LOW
		BL digitalWrite
		LDR R0, .DATA_PIN
		LDR R1, .CLOCK_PIN
		LDR R2, .MSBFIRST
		MOV R3, R4 
		BL shiftOut
		LDR R0, .LATCH_PIN 
		LDR R1, .HIGH
		BL digitalWrite
		MOV	R0, R5
		BL 	delay
		//up button
		LDR R0, .BUTTON1_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ increase_speed
		MOV R5, R0

		//down button
		LDR R0, .BUTTON2_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ decrease_speed
		MOV R5, R0
	sixth_step:
		MOV R4,#0b00100000
		LDR R0, .LATCH_PIN
		LDR R1, .LOW
		BL digitalWrite
		LDR R0, .DATA_PIN
		LDR R1, .CLOCK_PIN
		LDR R2, .MSBFIRST
		MOV R3, R4 
		BL shiftOut
		LDR R0, .LATCH_PIN 
		LDR R1, .HIGH
		BL digitalWrite
		MOV	R0, R5
		BL 	delay
		//up button
		LDR R0, .BUTTON1_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ increase_speed
		MOV R5, R0

		//down button
		LDR R0, .BUTTON2_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ decrease_speed
		MOV R5, R0
	seventh_step:
		MOV R4,#0b01000000
		LDR R0, .LATCH_PIN
		LDR R1, .LOW
		BL digitalWrite
		LDR R0, .DATA_PIN
		LDR R1, .CLOCK_PIN
		LDR R2, .MSBFIRST
		MOV R3, R4 
		BL shiftOut
		LDR R0, .LATCH_PIN 
		LDR R1, .HIGH
		BL digitalWrite
		MOV	R0, R5
		BL 	delay
		//up button
		LDR R0, .BUTTON1_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ increase_speed
		MOV R5, R0

		//down button
		LDR R0, .BUTTON2_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ decrease_speed
		MOV R5, R0
	eight_step:
		MOV R4,#0b10000000
		LDR R0, .LATCH_PIN
		LDR R1, .LOW
		BL digitalWrite
		LDR R0, .DATA_PIN
		LDR R1, .CLOCK_PIN
		LDR R2, .MSBFIRST
		MOV R3, R4 
		BL shiftOut
		LDR R0, .LATCH_PIN 
		LDR R1, .HIGH
		BL digitalWrite
		MOV	R0, R5
		BL 	delay
		//up button
		LDR R0, .BUTTON1_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ increase_speed
		MOV R5, R0

		//down button
		LDR R0, .BUTTON2_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ decrease_speed
		MOV R5, R0
	ninth_step:
		LSR R4, R4, #1
		LDR R0, .LATCH_PIN
		LDR R1, .LOW
		BL digitalWrite
		LDR R0, .DATA_PIN
		LDR R1, .CLOCK_PIN
		LDR R2, .MSBFIRST
		MOV R3, R4 
		BL shiftOut
		LDR R0, .LATCH_PIN 
		LDR R1, .HIGH
		BL digitalWrite
		MOV	R0, R5
		BL 	delay
		//up button
		LDR R0, .BUTTON1_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ increase_speed
		MOV R5, R0

		//down button
		LDR R0, .BUTTON2_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ decrease_speed
		MOV R5, R0
	tenth_step:
		MOV R4,#0b00100000
		LDR R0, .LATCH_PIN
		LDR R1, .LOW
		BL digitalWrite
		LDR R0, .DATA_PIN
		LDR R1, .CLOCK_PIN
		LDR R2, .MSBFIRST
		MOV R3, R4 
		BL shiftOut
		LDR R0, .LATCH_PIN 
		LDR R1, .HIGH
		BL digitalWrite
		MOV	R0, R5
		BL 	delay
		//up button
		LDR R0, .BUTTON1_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ increase_speed
		MOV R5, R0

		//down button
		LDR R0, .BUTTON2_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ decrease_speed
		MOV R5, R0
	eleventh_step:
		MOV R4,#0b00010000
		LDR R0, .LATCH_PIN
		LDR R1, .LOW
		BL digitalWrite
		LDR R0, .DATA_PIN
		LDR R1, .CLOCK_PIN
		LDR R2, .MSBFIRST
		MOV R3, R4 
		BL shiftOut
		LDR R0, .LATCH_PIN 
		LDR R1, .HIGH
		BL digitalWrite
		MOV	R0, R5
		BL 	delay
		//up button
		LDR R0, .BUTTON1_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ increase_speed
		MOV R5, R0

		//down button
		LDR R0, .BUTTON2_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ decrease_speed
		MOV R5, R0
	twelvth_step:
		MOV R4,#0b00001000
		LDR R0, .LATCH_PIN
		LDR R1, .LOW
		BL digitalWrite
		LDR R0, .DATA_PIN
		LDR R1, .CLOCK_PIN
		LDR R2, .MSBFIRST
		MOV R3, R4 
		BL shiftOut
		LDR R0, .LATCH_PIN 
		LDR R1, .HIGH
		BL digitalWrite
		MOV	R0, R5
		BL 	delay
		//up button
		LDR R0, .BUTTON1_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ increase_speed
		MOV R5, R0

		//down button
		LDR R0, .BUTTON2_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ decrease_speed
		MOV R5, R0
	thirteenth_step:
		MOV R4,#0b00000100
		LDR R0, .LATCH_PIN
		LDR R1, .LOW
		BL digitalWrite
		LDR R0, .DATA_PIN
		LDR R1, .CLOCK_PIN
		LDR R2, .MSBFIRST
		MOV R3, R4 
		BL shiftOut
		LDR R0, .LATCH_PIN 
		LDR R1, .HIGH
		BL digitalWrite
		MOV	R0, R5
		BL 	delay
		//up button
		LDR R0, .BUTTON1_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ increase_speed
		MOV R5, R0

		//down button
		LDR R0, .BUTTON2_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ decrease_speed
		MOV R5, R0
	fourteenth_step:
		MOV R4,#0b00000010
		LDR R0, .LATCH_PIN
		LDR R1, .LOW
		BL digitalWrite
		LDR R0, .DATA_PIN
		LDR R1, .CLOCK_PIN
		LDR R2, .MSBFIRST
		MOV R3, R4 
		BL shiftOut
		LDR R0, .LATCH_PIN 
		LDR R1, .HIGH
		BL digitalWrite
		MOV	R0, R5
		BL 	delay
		//up button
		LDR R0, .BUTTON1_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ increase_speed
		MOV R5, R0

		//down button
		LDR R0, .BUTTON2_PIN
		MOV R1, R5
		LDR R2, .PUD_DOWN
		BL waitForButton
		MOV R1, R5
		CMP R0, #1
		BEQ decrease_speed
		MOV R5, R0

	B knightRiderLoop

	increase_speed:
		CMP R1, #100
		BGT increase
		MOV R0, R1
		BX LR
		

	decrease_speed:
		add R0, R1, #100
		BX LR
	increase:
		sub R0, R1, #100
		BX LR
exit:
	MOV 	R7, #1				// System call 1, exit
	SWI 	0				// Perform system call


/*
-------------------------------------------------------------------------
 SUBROUTINES
-------------------------------------------------------------------------

If you wish, you can define your own subroutines here.
Make sure you save the registers on the stack to avoid conflicts.
Here is an example: 

foo: 
	STMDB SP!, {R3, R4, LR}
	// ... do something here with registers R3 and R4 ...
	LDMIA SP!, {R3, R4, PC} // end of foo subroutine, restore registers and jump


*/ 

waitForButton:
	/* 
	-----------------------------------------------------------------
	 Input arguments:
	 R0:	buttonPin
	 R1: 	timeout (millis)
	 R2: 	previous button state

	 Output:
	 R0:	1 if button pressed (falling edge), 0 otherwise
	 R1:	state of button (High/Low)
	-----------------------------------------------------------------
	*/
	STMDB SP!, {R2-R10, LR}

	MOV	R5, R0 		// R5: buttonPin
	MOV	R6, R1		// R6: timeout 
	MOV	R9, R2		// R9: (previous) button state
	MOV	R10, #0		// R10: button pressed or not

	@ get start time
	BL	millis
	MOV	R7, R0 		// R7: start time
	
	waitingLoopForButton:
	
		// read button pin state
		MOV	R0, R5
		BL	digitalRead
	
		// Check if edge is falling (1 -> 0)
		SUB	R1, R9, R0
		MOV	R9, R0			// previous = current
		CMP	R1, #1
		MOVEQ	R10, #1
	
		// compute elapsed time
		BL	millis
		SUB	R0, R0, R7
		
		// check if elapsed time < time out
		CMP	R0, R6
		BMI	waitingLoopForButton
		B	returnButtonPress

	returnButtonPress:
	MOV	R0, R10				// return 1 if button pressed within time window
	MOV	R1, R9
	LDMIA SP!, {R2-R10, PC}




// Constants for high- and low signals on the pins
.HIGH:			.word	1
.LOW:			.word	0

// The mode of the pin can be set to input or output.
.OUTPUT:		.word	1
.INPUT:			.word 	0

// For buttons (pull up / pull down)
.PUD_OFF:		.word	0
.PUD_DOWN:		.word	1
.PUD_UP:		.word	2

// For serial to parallel converter (74HC595 chip)
.LSBFIRST:		.word	0		// Least significant bit first
.MSBFIRST:		.word 	1		// Most significant bit first

.DATA_PIN:		.word	17 		// DS Pin of 74HC595 (Pin14)
.LATCH_PIN:		.word	27		// ST_CP Pin of 74HC595 (Pin12)	
.CLOCK_PIN:		.word	22		// CH_CP Pin of 74HC595 (Pin11)

// Button pins
.BUTTON1_PIN:		.word	18
.BUTTON2_PIN:		.word	25

