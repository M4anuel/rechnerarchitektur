/*
-----------------------------------------------------------
 Series 4 - Raspberry Pi Programming Part 1 - Running Light
 
 ** SOLUTION **

 Author: Adrian Wälchli

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
    LDR R0, .BUZZER_PIN
    LDR R1, .OUTPUT
    BL pinMode


start:

    LDR R0, .BUZZER_PIN
    LDR R1, .HIGH
    BL digitalWrite

    ldr r0, =#2000000
    bl   timer_wait  // 2second delay

    
    LDR R0, .BUZZER_PIN
    LDR R1, .LOW
    BL digitalWrite

    ldr r0, =#2000000
    bl   timer_wait  // 2second delay

    B start

exit:
	MOV 	R7, #1				// System call 1, exit
	SWI 	0				// Perform system call


/*
-------------------------------------------------------------------------
 SUBROUTINES
-------------------------------------------------------------------------
*/ 

;@ Entry: R0 = microseconds to wait ....  2 seconds = 2000000 usecs
;@ Change Pi_Base_Addr = 0x2000000 for Pi1 and PiZero, 0x3F000000 for Pi2/3
;@ set at Pi2/3 for demo
;@ to undesrtand what it does look at .... BCM2835 Manual Section 12
.globl timer_wait;
timer_wait:
        push    {r4, r5, lr}
        ldr     r2, .Pi_Base_Addr
.read_timer_loop1:
        ldr     r3, [r2]
        add     r3, r3, #12288
        ldr     ip, [r3, #8]
        ldr     r3, [r2]
        add     r3, r3, #12288
        ldr     lr, [r3, #4]
        ldr     r3, [r2]
        add     r3, r3, #12288
        ldr     r3, [r3, #8]
        cmp     ip, r3
        bne     .read_timer_loop1
        mov     r4, lr
        mov     r5, ip
.read_timer_loop2:
        ldr     r3, [r2]
        add     r3, r3, #12288
        ldr     ip, [r3, #8]
        ldr     r3, [r2]
        add     r3, r3, #12288
        ldr     lr, [r3, #4]
        ldr     r3, [r2]
        add     r3, r3, #12288
        ldr     r3, [r3, #8]
        cmp     ip, r3
        bne     .read_timer_loop2
        cmp     r5, ip
        cmpeq   r4, lr
        bhi     .read_timer_loop2
        pop     {r4, r5, pc}
.Pi_Base_Addr :
        .word   0x3F000000

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

.BUZZER_PIN:    .word   24

