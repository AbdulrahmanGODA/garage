.Include "M328Pdef.inc"

	.Cseg
	.ORG 0x0000 		;Location for reset  
		Jmp main  
	.ORG 0x0002 		;Location for external interrupt 0  
		Jmp externalISR0  
	.ORG 0x0004 		;Location for external interrupt 1  
		Jmp externalISR1  

.EQU LCD_DPRT = PORTB ;LCD DATA PORT
.EQU LCD_DDDR = DDRB ;LCD DATA DDR
.EQU LCD_DPIN = PINB ;LCD DATA PIN
.EQU LCD_CPRT = PORTC;LCD COMMANDS PORT
.EQU LCD_CDDR = DDRC ;LCD COMMANDS DDR
.EQU LCD_CPIN = PINC ;LCD COMMANDS PIN
.EQU LCD_RS = 0 ;LCD RS
.EQU LCD_RW = 1 ;LCD RW
.EQU LCD_EN = 2 ;LCD EN

main:
;set up stack
LDI R21,HIGH(RAMEND)
OUT SPH,R21 
LDI R21,LOW(RAMEND)
OUT SPL,R21
;initialize LCD
CALL LCD_INIT
CALL D_vehicle
;display '00'
LDI R16,0xC0 ;begins in the 2nd line
CALL CMNDWRT ;call command function
LDI R16,'0' 
CALL DATAWRT  
CALL DATAWRT
;initialize interrupt
CALL INT_INIT
;initialize counter
LDI R30,0X30
LDI R31,0x30

	HERE: JMP HERE ;stay here

;--------------------------------------------------------------------------------------------------;
externalISR0:
CLI
	;CALL DELAY_1s

	LDI R16,0x01 ;clear LCD
	CALL CMNDWRT ;call command function
	CALL DELAY_2ms ;delay 2 ms for clear LCD
	CALL D_vehicle
	LDI R16,0xC0 ;Begins at 2nd line
	CALL CMNDWRT ;call command function

	CPI R30,0x30
		BRNE False0
	True0:	CPI R31,0x30
				BRNE Here0
				Jmp End0
	False0:	CPI R31,0x30
				BRNE Here0
			LDI R31,0x3A
			DEC R30
	Here0:  DEC R31
	End0:	MOV R16,R30   
			CALL DATAWRT ;call data write function
			MOV R16,R31   
			CALL DATAWRT ;call data write function
SEI
			reti

externalISR1:
CLI
	;CALL DELAY_1s

	LDI R16,0x01 ;clear LCD
	CALL CMNDWRT ;call command function
	CALL DELAY_2ms ;delay 2 ms for clear LCD
	CALL D_vehicle
	LDI R16,0xC0 ;Begins at 2nd line
	CALL CMNDWRT ;call command function

	CPI R30,0x31
		BRNE False1
	True1:	CPI R31,0x36
				BRNE Here1
				JMP	End1
	False1:	CPI R31,0x39
				BRNE Here1
			LDI R31,0x2F
			INC R30
	Here1:  INC R31
			MOV R16,R30   
			CALL DATAWRT ;call data write function
			MOV R16,R31   
			CALL DATAWRT ;call data write function
			reti
	End1:
			CALL Full
SEI
			reti
;-------------------------------------------------------------------------------------------------;
CMNDWRT:
	MOV R27,R16
	SWAP R27 ;swap the nibbles
	OUT LCD_DPRT,R27 ;send the high nibble
	CBI LCD_CPRT,LCD_RS ;RS = 0 for command
	CBI LCD_CPRT,LCD_RW ;RW = 0 for write
	SBI LCD_CPRT,LCD_EN ;EN = 1 for high pulse  __-----
	CALL SDELAY ;make a wide EN pulse
	CBI LCD_CPRT,LCD_EN ;EN=0 for H-to-L pulse  ------__
	CALL DELAY_100us ;make a wide EN pulse
	MOV R27,R16
	OUT LCD_DPRT,R27 ;send the low nibble
	SBI LCD_CPRT,LCD_EN ;EN = 1 for high pulse __-----
	CALL SDELAY ;make a wide EN pulse
	CBI LCD_CPRT,LCD_EN ;EN=0 for H-to-L pulse  ----__
	CALL DELAY_100us ;wait 100 us
	RET
;--------------------------------------------------------------------------------------------------;
DATAWRT:
	MOV R27,R16
	SWAP R27 ;swap the nibbles
	OUT LCD_DPRT,R27 ;send the high nibble
	SBI LCD_CPRT,LCD_RS ;RS = 1 for data
	CBI LCD_CPRT,LCD_RW ;RW = 0 for write
	SBI LCD_CPRT,LCD_EN ;EN = 1 for high pulse
	CALL SDELAY ;make a wide EN pulse
	CBI LCD_CPRT,LCD_EN ;EN=0 for H-to-L pulse
	MOV R27,R16
	OUT LCD_DPRT,R27 ;send the low nibble
	SBI LCD_CPRT,LCD_EN ;EN = 1 for high pulse
	CALL SDELAY ;make a wide EN pulse
	CBI LCD_CPRT,LCD_EN ;EN=0 for H-to-L pulse
	CALL DELAY_100us ;wait 100 us
	RET
;--------------------------------------------------------------------------------------------------;
D_vehicle:
	LDI R16,'#' ;display letter '#'
	CALL DATAWRT 
	LDI R16,'V' ;display letter 'V'
	CALL DATAWRT 
	LDI R16,'E' ;display letter 'E'
	CALL DATAWRT 
	LDI R16,'H' ;display letter 'H'
	CALL DATAWRT
	LDI R16,'I' ;display letter 'I'
	CALL DATAWRT 
	LDI R16,'C' ;display letter 'C'
	CALL DATAWRT 
	LDI R16,'L' ;display letter 'L'
	CALL DATAWRT 
	LDI R16,'E' ;display letter 'E'
	CALL DATAWRT 
	LDI R16,'S' ;display letter 'S'
	CALL DATAWRT  
	LDI R16,0x20 ;display Space
	CALL DATAWRT
	LDI R16,'I' ;display letter 'I'
	CALL DATAWRT 
	LDI R16,'N' ;display letter 'N'
	CALL DATAWRT 
	LDI R16,'S' ;display letter 'S'
	CALL DATAWRT 
	LDI R16,'I' ;display letter 'I'
	CALL DATAWRT 
	LDI R16,'D' ;display letter 'D'
	CALL DATAWRT 
	LDI R16,'E' ;display letter 'E'
	CALL DATAWRT 
	RET
;--------------------------------------------------------------------------------------------------;
Full:
	LDI R16,0x01 ;clear LCD
	CALL CMNDWRT ;call command function
	CALL DELAY_2ms ;init. hold
	LDI R16,'F' ;display letter 'F'
	CALL DATAWRT 
	LDI R16,'U' ;display letter 'U'
	CALL DATAWRT 
	LDI R16,'L' ;display letter 'L'
	CALL DATAWRT
	LDI R16,'L' ;display letter 'L'
	CALL DATAWRT
	LDI R16,0x20 ;display Space
	CALL DATAWRT
	LDI R16,':' ;display letter ':'
	CALL DATAWRT
	LDI R16,'(' ;display letter '('
	CALL DATAWRT

	LDI R16,0xC0 ;Begins at 2nd line
	CALL CMNDWRT ;call command function
	CALL DELAY_2ms ;init. hold
	LDI R16,'G' ;display letter 'G'
	CALL DATAWRT 
	LDI R16,'O' ;display letter 'O'
	CALL DATAWRT 
	LDI R16,'D' ;display letter 'D'
	CALL DATAWRT 
	LDI R16,'A' ;display letter 'A'
	CALL DATAWRT
	LDI R16,0x20 ;display Space
	CALL DATAWRT
	LDI R16,'&' ;display letter '&'
	CALL DATAWRT 
	LDI R16,0x20 ;display Space
	CALL DATAWRT
	LDI R16,'E' ;display letter 'E'
	CALL DATAWRT 
	LDI R16,'L' ;display letter 'L'
	CALL DATAWRT
	LDI R16,'H' ;display letter 'H'
	CALL DATAWRT 
	LDI R16,'D' ;display letter 'D'
	CALL DATAWRT 
	LDI R16,'A' ;display letter 'A'
	CALL DATAWRT
	LDI R16,'D' ;display letter 'D'
	CALL DATAWRT 
	RET
;--------------------------------------------------------------------------------------------------;
INT_INIT:
	Ldi R30,0x00 		;Make INT0/INT1 LOW triggered  
	Sts EICRA,R30		;External Interrupt Control Register A
	Ldi R30,0x03		;Enable INT0/INT1 - 0b00000011
	Out EIMSK,R30		;External Interrupt MaSK
	Sei 				;Enable global interrupt  

	Sbi PORTD,2 		
	Sbi PORTD,3 		;Activated pull-up
	ret
;--------------------------------------------------------------------------------------------------;
LCD_INIT:
	LDI R21,0xFF
	OUT LCD_DDDR, R21 ;LCD data port (PORTB) is output
	OUT LCD_CDDR, R21 ;LCD command port (PORTC) is output

	LDI R16,0x33 ;init. LCD for 4-bit data
	CALL CMNDWRT ;call command function
	CALL DELAY_2ms ;init. hold

	LDI R16,0x32 ;init. LCD for 4-bit data
	CALL CMNDWRT ;call command function
	CALL DELAY_2ms ;init. hold

	LDI R16,0x28 ;init. LCD 2 lines,5×7 matrix
	CALL CMNDWRT ;call command function
	CALL DELAY_2ms ;init. hold

	LDI R16,0x0E ;display on, cursor on
	CALL CMNDWRT ;call command function

	LDI R16,0x01 ;clear LCD
	CALL CMNDWRT ;call command function
	CALL DELAY_2ms ;delay 2 ms for clear LCD

	LDI R16,0x06 ;shift cursor right
	CALL CMNDWRT ;call command function
	RET
;--------------------------------------------------------------------------------------------------;
SDELAY: 
	NOP
	NOP
	RET

DELAY_100us:
	PUSH R17
	LDI R17,60
DR0: CALL SDELAY
	DEC R17
	BRNE DR0
	POP R17
	RET

DELAY_2ms:
	PUSH R17
	LDI R17,20
LDR0: CALL DELAY_100US
	DEC R17
	BRNE LDR0
	POP R17
	RET

DELAY_1s:
	LDI R23, 82
LOOP3: LDI R22, 255
LOOP2: LDI R21, 255
LOOP1: DEC R21
		BRNE LOOP1
		DEC R22
		BRNE LOOP2
		DEC R23 
		BRNE LOOP3
		RET