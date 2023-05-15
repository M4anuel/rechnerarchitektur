/*
-----------------------------------------------------------
 Series 5 - Raspberry Pi Programming Part 1 - Paddle Ball

 Author: Manuel Flückiger

-----------------------------------------------------------
*/

.global main
.func main
.extern printf //for debugging 

main:
	// This will setup the wiringPi library.
	// In case something goes wrong, we exit the program
	BL	wiringPiSetupGpio		
	CMP	R0, #-1			
	BEQ	exit


configurePins:
	LDR	R0, .DATA_PIN
	LDR	R1, .OUTPUT
	BL	pinMode

	LDR	R0, .LATCH_PIN
	LDR	R1, .OUTPUT
	BL	pinMode

	LDR	R0, .CLOCK_PIN
	LDR	R1, .OUTPUT
	BL	pinMode

	// Button 1
	LDR	R0, .BUTTON1_PIN
	LDR	R1, .INPUT
	BL	pinMode

	LDR	R0, .BUTTON1_PIN
	LDR	R1, .PUD_UP
	BL	pullUpDnControl

	// Button 2
	LDR	R0, .BUTTON2_PIN
	LDR	R1, .INPUT
	BL	pinMode

	LDR	R0, .BUTTON2_PIN
	LDR	R1, .PUD_UP
	BL	pullUpDnControl

	// Buzzer
	LDR	R0, .BUZZER_PIN
	LDR	R1, .OUTPUT
	BL	pinMode
	
lobby:
		LDR	R0, .BUTTON2_PIN
		MOV	R1, #500			//Every every 0.5 seconds we refresh to see if the game should be restarted
		MOV	R2, #1				//default value
		BL	waitForButton
		CMP	R0, #1
		BEQ start				//once we pressed the button, we want to start
		B lobby					//infinite loop until you either start the game or exit with CTRL + c

start:
	MOV	R5, #0b00000001		// The position of the light is encoded as a one-hot binary pattern and
						    // the active bit will be moved using a left- and right-shift
	MOV R6, #0				// Binary value determining the direction (0: left-shift, 1: right-shift)
	MOV	R7, #500			// The time (in milliseconds) the running light is frozen

	MOV	R8, #1				// Previous state of BUTTON1 (default is off)
	MOV	R9, #1				// Previous state of BUTTON2 (default is off)

	MOV R10, #0				// keeps track of the score

knightRiderRestart:
	MOV	R4, #7				// A counter variable (counting down from 7 to 0)


knightRider:
	
	// Latch pin low (read serial data)
	LDR	R0, .LATCH_PIN
	LDR	R1, .LOW
	BL	digitalWrite
	
	CMP	R6, #1
	BNE	move_left
	B	move_right
	
	// Shift light to the left by one bit
	move_left:
	MOV	R5, R5, LSL #1
	B	send_data
	
	// Shift light to the right by one bit
	move_right:
	MOV	R5, R5, LSR #1
	B 	send_data
	
	// Send serial data
	send_data:
	LDR R0, .DATA_PIN
	LDR	R1, .CLOCK_PIN
	LDR	R2, .LSBFIRST
	MOV	R3, R5 
	BL	shiftOut

	// Latch pin high (write serial data to parallel output)
	LDR	R0, .LATCH_PIN
	LDR	R1, .HIGH
	BL	digitalWrite
	
	LDR	R0, .BUTTON1_PIN
	MOV	R1, R7
	MOV	R2, R8
	BL	waitForButton	
	CMP	R0, #1
	BEQ buttonPressed		// if the button isn't pressed, check, if it should've been
	CMP R5, #0b00000001
	BEQ scream				// if it should've been, scream & shout ;)
	CMP R5, #0b10000000
	BEQ scream
	B continue				// else continue

	buttonPressed:
		CMP R5, #0b00000001 // check if the button has been pressed at the correct time
		BEQ scorePoint

		CMP R5, #0b10000000
		BEQ scorePoint
		BNE scream			// else scream

	scream:
		LDR R0, .BUZZER_PIN
   		LDR R1, .HIGH
    	BL digitalWrite
		B continue

	scorePoint:
		ADD R10, R10, #1

	continue:

	MOV	R8, R1		// update button state (returned from subroutine)

	LDR R0, =string
    MOV R1, R10
	BL printf		// c printf function, debugging help

	SUBS	R4, R4, #1
	BNE	knightRider
	
	// Change direction (flip bit with XOR operation)
	EOR	R6, R6, #1
	CMP R7, #200
	BEQ endgame		// if the delay has reached 200ms, the game should be over, else 50ms is subtracted from the delay, to make it faster
	SUB R7, R7, #50
	B 	knightRiderRestart

	endgame:
		LDR R0, = finalString
    	MOV R1, R10
		BL printf		// again, c printf to debug
		LDR R0, .LATCH_PIN
		LDR R1, .LOW
		BL digitalWrite
		LDR R0, .DATA_PIN
		LDR R1, .CLOCK_PIN
		LDR R2, .MSBFIRST
		MOV R3, R10
		BL shiftOut 	// since the 54-AFHJ.... converts decimal to binary for us, we can just parse our score as int and it will be displayed correctly
		LDR R0, .LATCH_PIN 
		LDR R1, .HIGH
		BL digitalWrite 
		B lobby 		// after the game, return to the lobby


exit:
	MOV 	R7, #1				// System call 1, exit
	SWI 	0				// Perform system call

/*
-------------------------------------------------------------------------
 SUBROUTINES
-------------------------------------------------------------------------
*/ 

waitForButton:
	/* 
	-----------------------------------------------------------------
	 Input arguments:
	 R0:	buttonPin
	 R1: 	timeout (millis)
	 R2: 	previous button state

	 Output:
	 R0:	1 if button pressed, 0 otherwise
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
	LDR R0, .BUZZER_PIN
    LDR R1, .LOW
    BL digitalWrite
	MOV	R0, R10				// return 1 if button pressed within time window
	MOV	R1, R9
	LDMIA SP!, {R2-R10, PC}

// Define constants for high- and low signals on the pins
.HIGH:			.word	1
.LOW:			.word	0

// The mode of the pin can be set to input or output.
.OUTPUT:		.word	1
.INPUT:			.word 	0

.PUD_OFF:		.word	0
.PUD_DOWN:		.word	1
.PUD_UP:		.word	2

.LSBFIRST:		.word	0
.MSBFIRST:		.word 	1

.DATA_PIN:		.word	17 		// DS Pin of 74HC595 (Pin14)
.LATCH_PIN:		.word	27		// ST_CP Pin of 74HC595 (Pin12)	
.CLOCK_PIN:		.word	22		// CH_CP Pin of 74HC595 (Pin11)

.BUTTON1_PIN:		.word	18
.BUTTON2_PIN:		.word	25

.BUZZER_PIN:		.word	24

.data
string: .asciz "The score is: %d\n"
finalString: .asciz "The final score is: %d\n"
