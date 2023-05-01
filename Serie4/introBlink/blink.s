.global main
.func main

main:
	// This will setup the wiringPi library.
	// In case something goes wrong, we exit the program.
	BL	wiringPiSetupGpio
	CMP	R0, #-1
	BEQ	exit

configurePin:
	// Here we configure the pin.
	// We use the pin number 21 as defined at the bottom of 
	// this file and set the pin to output mode.
	LDR	R0, .LED_PIN
	LDR	R1, .OUTPUT
	BL	pinMode

blinkLoop:
	// This is where the loop for blinking the LED starts
	// Turn the LED on
	LDR	R0, .LED_PIN
	LDR	R1, .HIGH
	BL	digitalWrite

	// Wait 500 milliseconds
	MOV	R0, #500
	BL 	delay

	// Turn the LED off
	LDR	R0, .LED_PIN
	LDR	R1, .LOW
	BL	digitalWrite

	// Wait 500 milliseconds
	MOV	R0, #500
	BL	delay

	// Repeat
	B	blinkLoop

exit:
	MOV 	R7, #1
	SWI 	0


// We use GPIO pin 21 (BCM-style) to connect the LED.
.LED_PIN:		.word	21

// Define constants for high- and low signals on the pins
.HIGH:			.word	1
.LOW:			.word	0

// The mode of the pin can be set to input or output.
.OUTPUT:		.word	1
.INPUT:			.word 	0
