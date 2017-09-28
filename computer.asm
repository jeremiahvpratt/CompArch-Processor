	LIST	P=PIC16F877A
	include <p16F877A.inc>

	__CONFIG _HS_OSC & _WDT_OFF & _PWRTE_ON & _CP_OFF & _LVP_OFF
	

PC	EQU 0xA0		; Program Counter
INS1 EQU 0xA2		; Instruction 1
INS2 EQU 0xA3		; Instruction 2
TEMP1 EQU 0XA4		; Temporary work variable 1
TEMP2 EQU 0xA5		; Temporary work variable 2
VAR_I EQU 0XA6		; testing delay variable
VAR_J EQU 0XA7		;testing delay variable
POINTER EQU 0XA8	; temporary varible for pointer
SC EQU 0XA9


R0	EQU	0xB0		; WE NEED 16 REGISTERS
R1	EQU	0xB1
R2	EQU	0xB2
R3	EQU	0xB3
R4	EQU	0xB4
R5	EQU	0xB5
R6	EQU	0xB6
R7	EQU	0xB7
R8	EQU	0xB8
R9	EQU	0xB9
R10	EQU	0xBA
R11	EQU	0xBB
R12	EQU	0xBC
R13	EQU	0xBD
R14	EQU	0xBE		; BANK SELECT REGISTER
R15	EQU	0xBF		; R15 stores "0000 00ZC"

BANK0 EQU 0XC0		; DATA MEMORY, THEORETICALLY SHOULD BE SEPARATE FROM PROCESSSOR
					; ALSO ONLY 60 BYTES, DIDN'T WANT TO FIX IMPLEMENTATION OF OTHER
					; VARIABLES.

;E0 = OE
;E1 = Read
;E2 = Write
;MSB of PortB = address
;6 bits of A plus D7 will be output

	ORG 0x2100		; Access EEPROM
	de 0x80, 0x09, 0x81, 0x05, 0x12, 0x01, 0x22, 0x01, 0x32, 0x01, 0x42, 0x01, 0x52, 0x01, 0x62, 0x01, 0x62, 0x81, 0x72, 0x01	; Set instructions in EEPROM
	;de 0x80, 0x09, 0x62, 0x00, 0x62, 0x80
	;de 0x8E, 0x0F, 0x80, 0x00, 0x81, 0x00, 0x82, 0x01, 0x11, 0x12, 0xBF, 0x00, 0x10, 0x02, 0xA0, 0x02, 0xC0, 0x04
	;de 0x8E, 0x0F, 0x80, 0x0F, 0x81, 0x0F, 0xA0, 0x00
	ORG 0x00

	goto	start

	ORG 0x10
start
	bsf STATUS, RP0	; Bank 1
	bcf STATUS, RP1 ; 
	movlw 	0x06	; '0000 0110'
	movwf 	ADCON1	;
	movlw 	0x00	; Set all output
	movwf	TRISC	; in PORTC
	movlw	0x00	; Set 4 all to output
	movwf	TRISB	; in PORTB
	movlw	0xff	; Set all to input
	movwf	TRISD	; in PORTD
	movlw   0x07	; set "0111"
	movwf   TRISE	; in PORTE
	

L0	
	;goto L400
	movlw .50					;THIS BE SOME DELAY SHIT FOR TESTING
	movwf VAR_I	

L200	movlw .100
		movwf VAR_J

L300		nop
			nop
			nop
			nop
			nop
			nop
			nop
		decfsz	VAR_J, F
		goto	L300
	
	decfsz	VAR_I, F
	goto	L200 

L400

	call READ1
	movwf   INS1	; Send first instruction byte to INS1
	call READ2
	movwf	INS2	; Send secon instruction byte to INS2

	btfss	INS1, 7	; If pin 7 of B is 0
		goto	L1		; Jump to branch 0
	btfsc	INS1, 7	; If pin 7 of B is 1
		goto	L2		; Jump to branch 1

L1						; BRANCH 0

	btfss	INS1, 6	; If pin 6 of B is 0
		goto L3			; Jump to branch 0.0
	btfsc	INS1, 6	; If pin 6 of B is 1
		goto L4			; Jump to branch 0.1

L3						; BRANCH 0.0

	btfss	INS1, 5	; If pin 5 of B is 0
		goto L5			; Jum p to branch 0.0.0
	btfsc	INS1, 5	; If pin 5 of B is 1
		goto L6			; Jump to branch 0.0.1

L4						; BRANCH 0.1

	btfss	INS1, 5	; If pin 5 of B is 0
		goto L11		; Jump to branch 0.1.0
	btfsc	INS1, 5	; If pin 5 of B is 1
		goto L12		; Jump to branch 0.1.1

L11						; BRANCH 0.1.0

	btfss 	INS1, 4	; If pin 4 of B is 0
		goto L13		; Jump to branch 0.1.0.0
	btfsc	INS1, 4	; If pin 4 of B is 1
		goto L14		; Jump to branch 0.1.0.1

L12						; BRANCH 0.1.1

	btfss	INS1, 4	; If pin 4 of B is 0
		goto L15		; Jump to branch 0.1.1.0
	btfsc	INS1, 4	; If pin 4 of B is 1
		goto L16			; Jump to branch 0.1.1.1

L5						; BRANCH 0.0.0

	btfss	INS1, 4	; If pin 4 of B is 0
		goto L7			; Jump to branch 0.0.0.0
	btfsc 	INS1, 4	; If pin 4 of B is 1
		goto L8			; Jump to branch 0.0.0.1

L6						; BRANCH 0.0.1

	btfss	INS1, 4	; If pin 4 of B is 0
		goto L9			; Jump to branch 0.0.1.0
	btfsc 	INS1, 4	; If pin 4 of B is 1
		goto L10		; Jump to branch 0.0.1.1

L2						; BRANCH 1

	btfss	INS1, 6	; If6pin 6 of B is 0
		goto L17		; jump to branch 1.0
	btfsc	INS1, 6	; If pin 6 of B is 1
		goto L18		; jump to branch 1.1

L17						; BRANCH 1.0

	btfss	INS1, 5	; If pin 5 of B is 0
		goto L19		; jump to branch 1.0.0
	btfsc	INS1, 5	; If pin 5 of B is 1
		goto L20		; jump to branch 1.0.1

L19						; BRANCH 1.0.0

	btfss 	INS1, 4	; If pin 4 of B is 0
		goto L21		; jump to branch 1.0.0.0
	btfsc	INS1, 4	; If pin 4 of B is 1
		goto L22		; jump to branch 1.0.0.1

L20						; BRANCH 1.0.1

	btfss 	INS1, 4	; If pin 4 of B is 0
		goto L23		; jump to branch 1.0.1.0
	btfsc	INS1, 4	; If pin 4 of B is 1
		goto L24		; jump to branch 1.0.1.1

L18						; BRANCH 1.1

	btfss	INS1, 5	; If pin 5 of B is 0
		goto L25		; jump to branch 1.1.0
	btfsc	INS1, 5 ; If pin 5 of B is 1
		goto L26		; jump to branch 1.1.1

L25						; BRANCH 1.1.0

	btfss	INS1, 4	; If pin 4 of B is 0
		goto L27		; jmp to branch 1.1.0.0
	btfss	INS1, 4	; If pin 4 of B is 1
		goto L28		; jump to branch 1.1.0.1

L26						; BRANCH 1.1.1

	btfss	INS1, 4	; If pin 4 of B is 0
		goto L29		; jump to branch 1.1.1.0
	btfsc	INS1, 4	; If pin 4 of B is 1
		goto L30		; jump to branch 1.1.1.1


 

L7						; BRANCH 0.0.0.0
						; NO OPERATION
	nop
	incf	PC, F		; Add one to program counter
	goto	L0			; Go back to start I guess
	
L8						; BRANCH 0.0.0.1
						; ADDITION

	call GRABBC			; w now stores combined values pointed to by "BBBB CCCC"
	bcf STATUS, RP0		; Bank 0
	movwf PORTC			; Port C now equal to values of "BBBB CCCC"
	movlw	0x07		; put "0000 0111" in w
	movwf PORTB			; B now outputs "0111"
	nop
	nop
	nop
	nop
	movfw PORTD			; w stores input from D, the output of the ALU
	bsf STATUS, RP0		; Bank 1
	movwf TEMP1			;
	movwf TEMP2
	bcf	TEMP1, 7		; clearing extra bits just in case
	bcf TEMP1, 6		;
	bcf TEMP1, 5		;
	bcf TEMP1, 4		;
	bcf TEMP2, 7
	bcf TEMP2, 6
	bcf TEMP2, 3
	bcf TEMP2, 2
	bcf TEMP2, 1
	bcf TEMP2, 0
	movfw TEMP2
	movwf POINTER
	call POINTA			; retrieve pointer to register location aaaa
	movfw TEMP1			;
	movwf INDF			; store  
	movlw 0xBF
	movwf FSR
	swapf POINTER, 0
	movwf INDF
	
	incf	PC, F
	goto L0


L9						; BRANCH 0.0.1.0
						; SUBTRACTION

	call GRABBC			; w has "bbbb cccc" values
	bcf STATUS, RP0		; Bank 0
	movwf PORTC			; Port C now equals "bbbb cccc" values
	movlw	0x06		; put "0000 0110" in w
	movwf PORTB			; B outputs "0111"
	nop
	nop
	nop
	nop	
	movfw PORTD			; w stores input from D, output of ALU
	bsf STATUS, RP0		; Bank 1
	movwf TEMP1			;
	bcf TEMP1, 7		; clearing extra bits just in case
	bcf TEMP1, 6		;
	bcf TEMP1, 5		;
	bcf TEMP1, 4		;
	call POINTA			; retrieves pointer to register location aaaa
	movfw TEMP1			;
	movwf INDF			; store

	incf	PC, F
	goto L0

L10						; BRANCH 0.0.1.1
						; AND

	call GRABBC			; w has "bbbb cccc" values
	bcf STATUS, RP0		; Bank 0
	movwf PORTC			; Port C now equals "bbbb cccc" values
	movlw	0x00		; put "0000 0000" in w
	movwf PORTB			; B outputs "0000"
	nop
	nop
	nop
	nop	
	movfw PORTD			; w stores input from D, output of ALU
	bsf STATUS, RP0		; Bank 1
	movwf TEMP1			;
	bcf TEMP1, 7		; clearing extra bits just in case
	bcf TEMP1, 6		;
	bcf TEMP1, 5		;
	bcf TEMP1, 4		;
	call POINTA			; retrieves pointer to register location aaaa
	movfw TEMP1			;
	movwf INDF			; store

	incf	PC, F
	goto L0

L13						; BRANCH 0.1.0.0
						; OR

	call GRABBC			; w has "bbbb cccc" values
	bcf STATUS, RP0		; Bank 0
	movwf PORTC			; Port C now equals "bbbb cccc" values
	movlw	0x01		; put "0000 0001" in w
	movwf PORTB			; B outputs "0001"
	nop
	nop
	nop
	nop	
	movfw PORTD			; w stores input from D, output of ALU
	bsf STATUS, RP0		; Bank 1
	movwf TEMP1			;
	bcf TEMP1, 7		; clearing extra bits just in case
	bcf TEMP1, 6		;
	bcf TEMP1, 5		;
	bcf TEMP1, 4		;
	call POINTA			; retrieves pointer to register location aaaa
	movfw TEMP1			;
	movwf INDF			; store

	incf	PC, F
	goto L0

L14						; BRANCH 0.1.0.1
						; XOR

	call GRABBC			; w has "bbbb cccc" values
	bcf STATUS, RP0		; Bank 0
	movwf PORTC			; Port C outpus "bbbb cccc" values
	movlw 0x02			; put "0000 0010" in w
	movwf PORTB
	nop
	nop
	nop
	nop
	movfw PORTD			; w stores input from D, output of ALU
	bsf STATUS, RP0		; Bank 1
	movwf TEMP1			;
	bcf TEMP1, 7		; clearing extra bits just in case
	bcf TEMP1, 6		;
	bcf TEMP1, 5		;
	bcf TEMP1, 4		;
	call POINTA			; retrieves pointer to register location aaaa
	movfw TEMP1			;
	movwf INDF			; store

	incf	PC, F	
	goto L0	 

L15						; BRANCH 0.1.1.0
						; RRL/RRR

	call GRABC			; W NOW stores "0000 bbbb"
	bcf STATUS, RP0		; bank 0
	movwf PORTC			; Port C outputs "0000 bbbb" values
	swapf PORTC	,1
		; Swap it, cuz the ALU wants A inputs for shifting
	bsf STATUS, RP0		; bank 1
	btfss INS2, 7
		movlw 0x03			; Put "0000 0011" in w
	btfsc INS2, 7
		movlw 0x04			; Put "0000 0100" in w
	bcf STATUS, RP0		; bank 0 
	movwf PORTB			;
	nop
	nop
	nop
	nop
	movfw PORTD			; w stores input from D, output of ALU
	bsf STATUS, RP0
	movwf TEMP1			;
	bcf TEMP1, 7		; clearing extra bits just in case
	bcf TEMP1, 6		;
	bcf TEMP1, 5		;
	bcf TEMP1, 4		;
	call POINTA			; retrieves pointer to register location AAAA
	movfw TEMP1			;
	movwf INDF			; store

	incf	PC, F
	goto L0

L16						; BRANCH 0.1.1.1
						; NOT

	call GRABC			; put "0000 bbbb" into w
	bcf STATUS, RP0		; bank 0
	movwf PORTC			; port c outputs "0000 bbbb" values
	swapf PORTC, 1		; swap it, cuz the ALU wants A inputs for NOT
	movlw 0x05			; put "0000 0101" in w
	movwf PORTB			;
	nop
	nop
	nop
	nop
	movfw PORTD			; w stores input from D, output of ALU
	bsf STATUS, RP0
	movwf TEMP1			;
	bcf TEMP1, 7		; clearing extra bits just in case
	bcf TEMP1, 6		;
	bcf TEMP1, 5		;
	bcf TEMP1, 4		;
	call POINTA			; retrieves pointer to register location AAAA
	movfw TEMP1			;
	movwf INDF			; store

	incf	PC, F
	goto L0
	

L21						; BRANCH 1.0.0.0
						; MOV
	btfss INS2, 7		; if * is low
		movfw INS2		; move "*XXX kkkk" into w
	btfsc INS2, 7		; if * is high
		call GRABB		; w stores "0000 bbbb"
	movwf TEMP1			; put whatever in TEMP1
	bcf TEMP1, 7		; clearing extra bits just in case
	bcf TEMP1, 6		;
	bcf TEMP1, 5		;
	bcf TEMP1, 4		;
	call POINTA			;
	movfw TEMP1			; put it back into w
	movwf INDF			; store it where AAAA points

	incf	PC, F
	goto L0
		

L22						; BRANCH 1.0.0.1
						; LOD
	btfss R14, 3		; If R14 is 0XXX
		goto L221		;
	btfsc R14, 3		; If R14 is 1XXX
		goto L222		;

	L221
		btfss INS2, 7	; If * is low
			goto L2210
		btfsc INS2, 7	; If * is high
			goto L2211
		L2210			; OFFSET K
			movlw 0xC0	;
			bcf INS2, 7	;
			addwf INS2,0	;
			goto L221E ;
		
		L2211			; OFFSET SPECIFIED BY REGISTERS
			call GRABBTWICE
			movwf TEMP1	;
			bcf TEMP1, 7;
			movfw TEMP1		;
			addlw 0xC0			
			goto L221E		
	
	L221E	
		movwf FSR		; put this in that pointing crap
		movf INDF, W	; put the thing that points to into W
		movwf TEMP1		;
		movf INDF, W	;
		movwf TEMP2		;
		bcf TEMP1, 3
		bcf TEMP1, 2
		bcf TEMP1, 1
		bcf TEMP1, 0
		bcf TEMP2, 7
		bcf TEMP2, 6
		bcf TEMP2, 5
		bcf TEMP2, 4
		bcf INS1, 7
		bcf INS1, 6
		bcf INS1, 5
		bcf INS1, 4
		swapf TEMP1, 1	;temp 1 stores 4 MSBS of the bank
		movfw INS1
		addlw 0xB0
		movwf FSR		
		movfw TEMP1
		movf INDF, W	;it gets stored in register aaaa
		movfw INS1
		addlw 0xB1
		movwf FSR
		movfw TEMP2		;temp 2 stores 4 LSBS of the bank
		movf INDF, W	;it gets stored in register aaaa + 1
	
		incf PC, F
		goto L0

	L222				; THIS WHEN YOU INPUTTING
		
	
		movlw 0x3F
		movwf TRISA
		movlw 0xFF
		movwf TRISD
		btfss INS2, 7	; If * is low
			goto L2220
		btfsc INS2, 7	; If * is high
			goto L2221
		L2220			; OFFSET K
			bcf INS2, 7	;
			bcf INS2, 6
			bcf INS2, 5
			bcf INS2, 4
			swapf INS2, 0
			goto L222E ;
		
		L2221			; OFFSET SPECIFIED BY REGISTERS
			call GRABBTWICE
			movwf TEMP1	;
			bcf TEMP1, 7;
			bcf TEMP1, 6;
			bcf TEMP1, 5
			bcf TEMP1, 4
			swapf TEMP1, 0		;			
			goto L222E
	
	L222E
		bcf STATUS, RP0
		movwf PORTB	
		movlw 0x03
		movwf PORTE		; assert "0011" in E (read, OE both high)
		nop
		nop
		nop
		movfw PORTA		; this part is tricky
		bsf STATUS, RP0	
		movwf TEMP1		; set it aside for now
		bcf STATUS, RP0
		movfw PORTD		; again tricky
		bsf STATUS, RP0
		movwf TEMP2		; now we play with them
		bcf STATUS, RP0
		movlw 0x00
		movwf PORTE
		bsf STATUS, RP0
		bcf TEMP2, 5
		bcf TEMP2, 4
		bcf TEMP2, 3
		bcf TEMP2, 2
		bcf TEMP2, 1
		bcf TEMP2, 0
		movfw TEMP1
		addwf TEMP2,0		; now it's stored properly thank god
		movwf TEMP1
		movfw TEMP1
		movwf TEMP2
		bcf TEMP1, 3
		bcf TEMP1, 2
		bcf TEMP1, 1
		bcf TEMP1, 0
		bcf TEMP2, 7
		bcf TEMP2, 6
		bcf TEMP2, 5
		bcf TEMP2, 4
		bcf INS1, 7
		bcf INS1, 6
		bcf INS1, 5
		bcf INS1, 4
		swapf TEMP1, 1	;temp 1 stores 4 MSBS of the bank
		movfw INS1
		addlw 0xB0
		movwf FSR		
		movfw TEMP1
		movf INDF, W	;it gets stored in register aaaa
		movfw INS1
		addlw 0xB1
		movwf FSR
		movfw TEMP2		;temp 2 stores 4 LSBS of the bank
		movf INDF, W	;it gets stored in register aaaa + 1
			
		incf PC, F
		goto L0
		

L23						; BRANCH 1.0.1.0
						; STO
	btfss R14, 3		; If R14 is 0XXX
		goto L231		;
	btfsc R14, 3		; If R14 is 1XXX
		goto L232		;

	L231
		btfss INS2, 7	; If * is low
			goto L2310
		btfsc INS2, 7	; If * is high
			goto L2311
		L2310			; OFFSET K
			movlw 0xC0	;
			bcf INS2, 7	;
			addwf INS2,0	;
			goto L231E ;
		
		L2311			; OFFSET SPECIFIED BY REGISTERS
			call GRABBTWICE
			movwf TEMP1	;
			bcf TEMP1, 7;
			movfw TEMP1		;
			addlw 0xC0			
			goto L231E
	L231E
			movwf POINTER	; pointing to place in bank that we want
			movfw INS1
			movwf TEMP1
			bcf TEMP1, 7
			bcf TEMP1, 6
			bcf TEMP1, 5
			bcf TEMP1, 4
			movfw TEMP1
			addlw 0xB0
			movwf TEMP1
			movfw TEMP1
			addlw 0x01
			movwf TEMP2
			movfw TEMP1
			movwf FSR
			movf INDF, W
			movwf TEMP1
			movfw TEMP2
			movwf FSR
			movf INDF, W
			movwf TEMP2
			bcf TEMP1, 7
			bcf	TEMP1, 6
			bcf	TEMP1, 5
			bcf	TEMP1, 4
			bcf TEMP2, 7
			bcf TEMP2, 6
			bcf	TEMP2, 5
			bcf TEMP2, 4
			swapf TEMP1, 0
			addwf TEMP2, 0
			movwf TEMP1
			movfw POINTER
			movwf FSR
			movfw TEMP1
			movf INDF, W
	
			incf PC, F
			goto L0
	L232				; if you outputting

		movlw 0x00
		movwf TRISA
		movlw 0x3F
		movwf TRISD
		
		btfss INS2, 7	; If * is low
			goto L2320
		btfsc INS2, 7	; If * is high
			goto L2321
		L2320			; OFFSET K
			bcf INS2, 7	;
			bcf INS2, 6
			bcf INS2, 5
			bcf INS2, 4
			swapf INS2, 0
			goto L232E ;
		
		L2321			; OFFSET SPECIFIED BY REGISTERS
			call GRABBTWICE
			movwf TEMP1	;
			bcf TEMP1, 7;
			bcf TEMP1, 6;
			bcf TEMP1, 5
			bcf TEMP1, 4
			swapf TEMP1, 0		;			
			goto L232E

	L232E
			bcf STATUS, RP0
			movwf PORTB
			bsf STATUS, RP0
			movfw INS1
			movwf TEMP1
			bcf TEMP1, 7
			bcf TEMP1, 6
			bcf TEMP1, 5
			bcf TEMP1, 4
			movfw TEMP1
			addlw 0xB0
			movwf TEMP1
			movfw TEMP1
			addlw 0x01
			movwf TEMP2
			movfw TEMP1
			movwf FSR
			movf INDF, W
			movwf TEMP1
			movfw TEMP2
			movwf FSR
			movf INDF, W
			movwf TEMP2
			bcf TEMP1, 7
			bcf	TEMP1, 6
			bcf	TEMP1, 5
			bcf	TEMP1, 4
			bcf TEMP2, 7
			bcf TEMP2, 6
			bcf	TEMP2, 5
			bcf TEMP2, 4
			swapf TEMP1, 0
			addwf TEMP2, 0
			movwf TEMP1
			movfw TEMP1
			movwf TEMP2
			bcf TEMP1, 5
			bcf TEMP1, 4
			bcf	TEMP1, 3
			bcf TEMP1, 2
			bcf TEMP1, 1
			bcf TEMP1, 0
			bcf TEMP2, 7
			bcf TEMP2, 6
			movfw TEMP2
			bcf STATUS, RP0
			movwf PORTA
			movlw 0x01
			movwf PORTE			; assert OE
			bsf STATUS, RP0
			movfw TEMP1
			bcf STATUS, RP0
			movwf PORTD
			movlw 0x05			; assert write, OE
			movwf PORTE
			nop
			nop
			nop
			movlw 0x00
			movwf PORTE			; clear instructions

			bsf STATUS, RP0

			incf PC, F
			goto L0

	
		

L24						; BRANCH 1.0.1.1
						; TSC
	btfss INS2, 7		; if * is 0
		goto L240
	btfsc INS2, 7		; if * is 1
		goto L241

	L240
	btfss INS2, 1
		goto L2400
	btfsc INS2, 1
		goto L2401

	L241
	btfss INS2, 1
		goto L2410
	btfsc INS2, 1
		goto L2411

	L2400
	btfss INS2, 0
		goto L24000
	btfsc INS2, 0
		goto L24001

	L2401
	btfss INS2, 0
		goto L24010
	btfsc INS2, 0
		goto L24011

	L2410
	btfss INS2, 0
		goto L24100
	btfsc INS2, 0
		goto L24101

	L2411
	btfss INS2, 0
		goto L24110
	btfsc INS2, 0
		goto L24111

	L24000			; skip if 00 is low
	call GRABA		;
	movwf TEMP1
	btfss TEMP1, 0
		incf PC, F

	incf PC, F
	goto L0

	L24001			; skip if 01 is low
	call GRABA
	movwf TEMP1
	btfss TEMP1, 1
		incf PC, F

	incf PC, F
	goto L0

	L24010			; skip if 10 is low
	call GRABA
	movwf TEMP1
	btfss TEMP1, 2
		incf PC, F

	incf PC, F
	goto L0

	L24011			; skip if 11 is low
	call GRABA
	movwf TEMP1
	btfss TEMP1, 3
		incf PC, F

	incf PC, F
	goto L0

	L24100			; skip if 00 is high
	call GRABA
	movwf TEMP1
	btfsc TEMP1, 0
		incf PC, F

	incf PC, F
	goto L0

	L24101			; skip if 01 is high
	call GRABA
	movwf TEMP1
	btfsc TEMP1, 1
		incf PC, F

	incf PC, F
	goto L0

	L24110			; skip if 10 is high
	call GRABA
	movwf TEMP1
	btfsc TEMP1, 2
		incf PC, F

	incf PC, F
	goto L0

	L24111			; skip if 11 is high
	call GRABA
	movwf TEMP1
	btfsc TEMP1, 3
		incf PC, F

	incf PC, F
	goto L0

L27						; BRANCH 1.1.0.0
						; JMP
	btfss INS1, 3
		goto L270
	btfsc INS1, 3
		goto L271

	L270
		bcf INS2, 7
		movfw INS2
		movwf PC
		goto L0

	L271
		movfw INS2
		movwf TEMP1
		bcf TEMP1, 7
		bcf TEMP1, 6
		bcf TEMP1, 5
		bcf TEMP1, 4
		movfw TEMP1
		addlw 0xB1
		movwf FSR
		movf INDF, W
		movwf TEMP2
		swapf TEMP2, 1
		bcf TEMP2, 7
		movfw TEMP1
		addlw 0xB2
		movwf FSR
		movf INDF, W
		movwf TEMP1
		movfw TEMP2
		addwf TEMP1, 0

		movwf PC
		goto L0
		

L28						; BRANCH 1.1.0.1
						; JSR
		movfw SC
		addlw 0xAA
		movwf FSR
		movfw PC
		addlw 0x01
		movwf INDF
		incf SC, F
		
	btfss INS1, 3
		goto L280
	btfsc INS1, 3
		goto L281

	L280
		bcf INS2, 7
		movfw INS2
		movwf PC
		goto L0

	L281
		movfw INS2
		movwf TEMP1
		bcf TEMP1, 7
		bcf TEMP1, 6
		bcf TEMP1, 5
		bcf TEMP1, 4
		movfw TEMP1
		addlw 0xB1
		movwf FSR
		movf INDF, W
		movwf TEMP2
		swapf TEMP2, 1
		bcf TEMP2, 7
		movfw TEMP1
		addlw 0xB2
		movwf FSR
		movf INDF, W
		movwf TEMP1
		movfw TEMP2
		addwf TEMP1,0

		movwf PC
		goto L0
		

L29						; BRANCH 1.1.1.0
						; RET
		movfw SC
		addlw 0xAA
		movwf FSR
		movf INDF, W
		movwf PC
		decf SC, F
		goto L0
		

L30						; BRANCH 1.1.1.1


READ1						; READS NEXT 8 BIT NUMBER FROM EEPROM
	movfw PC				; Move program counter into w
	addwf PC, 0				;
	bsf	STATUS, RP1			;
	bcf	STATUS, RP0			; Bank 2
	movwf EEADR				; Address to read
	bsf	STATUS, RP0			; Bank 3
	bcf	EECON1, EEPGD		; Point to Data memory
	bsf	EECON1, RD			; EE Read
	bcf	STATUS, RP0			; Bank 2
	movfw EEDATA			; W = EEDATA
	bsf STATUS, RP0		
	bcf	STATUS, RP1			; Bank 1
	return

READ2						; READS SECOND 8 BIT NUMBER, OFFSET 1
	movfw PC				;same as above
	addwf PC, 0				;
	addlw 0x01				; offset by 1, get second byte of machine code
	bsf STATUS, RP1			;
	bcf STATUS, RP0			; Bank 2
	movwf EEADR				; Address to read
	bsf STATUS, RP0			; Bank 3
	bcf EECON1, EEPGD		; pOINT TO DATA MEMORY
	bsf EECON1, RD			; EE read
	bcf STATUS, RP0			; Bank 2
	movfw EEDATA			; W = EEDATA
	bsf STATUS, RP0			; 
	bcf STATUS, RP1			; Bank 1
	return

POINTA						; MOVES "aaaa" INSTRUCTION SET INTO FSR
							; TO ALLOW STORAGE AT REFERENCED REGISTER
	bcf STATUS, RP1
	bsf STATUS, RP0			; Bank 1
	movfW INS1
	movwf TEMP2				; Move "MMMM AAAA" to TEMP1
	bcf TEMP2, 7			; clearing extra bits
	bcf TEMP2, 6
 	bcf TEMP2, 5
	bcf TEMP2, 4
	movfw TEMP2			; move "0000 AAAA" to W
	addlw 0xB0				; Push to offset register
	movwf FSR				;
	return

GRABA						;PLACES CONTENTS OF REGISTER POINTED TO BY A INTO W
	bcf STATUS, RP1			;
	bsf STATUS, RP0			; Bank 1
	movfw INS1
	movwf TEMP1				; Move instruction set 1 "MMMM AAAA" to TEMP1
	bcf	TEMP1, 7			; clearing extra bits
	bcf TEMP1, 6			;
	bcf	TEMP1, 5			;
	bcf	TEMP1, 4			;
	movfw TEMP1				; Move "0000 AAAA" to W
	addlw 0xB0				; Push to offset register
	movwf FSR				; 
	movf	INDF, W			; Move contents at 0xB0 + AAAA to W
	return

GRABB						;PLACES CONTENTS OF REGISTER POINTED TO BY B INTO W
	bcf STATUS, RP1			;
	bsf STATUS, RP0			; Bank 1
	movfw INS2	
	movwf TEMP1				; Move instruction set 2 "BBBB CCCC" to TEMP1
	bcf TEMP1, 3			; clearing extra bits
	bcf TEMP1, 2			;
	bcf TEMP1, 1			;
	bcf TEMP1, 0			;
	swapf TEMP1, 0			; swap the nibbles of TEMP1 and move it into W
	addlw 0xB0				; Push to offset register
	movwf FSR
	movf	INDF, W			; Move contents at 0xB0 + BBBB to W
	return

GRABC						; PLACES CONTENTS OF REGISTER POINTED TO BY C INTO W
	bcf STATUS, RP1			;
	bsf STATUS, RP0			; Bank 1
	movfw INS2
	movwf TEMP1				; Move instruction set 2 "BBBB CCCC" to TEMP1
	bcf TEMP1, 7			; clearing extra bits
	bcf TEMP1, 6			;
	bcf TEMP1, 5			;
	bcf TEMP1, 4			;
	movfw TEMP1				; moving "0000 CCCC" to w
	addlw 0xB0				; adding offset
	movwf FSR
	movf	INDF, W			; Move contents at 0xBO + CCCC to W
	return

GRABBC						; PLACES CONTENTS OF ADDRESSES POINTED TO BY
							; "BBBB" AND "CCCC" CONCANTENATED TOGETHER IN W
							; IN FORMAT "bbbb cccc"
	bcf STATUS, RP1
	bsf STATUS, RP0			; Bank 1
	movfw INS2
	movwf TEMP1				; Move instruction set 2 "BBBB CCCC' to Temp1
	movfw INS2
	movwf TEMP2				; Move instruction set 2 "BBBB CCCC" to Temp2
	bcf TEMP1, 7			; Clearing B's from Temp1
	bcf TEMP1, 6			;
	bcf TEMP1, 5			;
	bcf TEMP1, 4			;
	movfw TEMP1				; moving "0000 CCCC" to w
	addlw 0xB0				; add offset
	movwf FSR				
	movf	INDF, W			; Move contents at 0xB0 + CCCC to W
	movwf TEMP1				; Contents from 0xB0 + CCCC now in TEMP1
	bcf TEMP2, 3			; Clearing C's from Temp2
	bcf TEMP2, 2			;
	bcf TEMP2, 1			; 
	bcf TEMP2, 0			;
	swapf TEMP2, 0			; swap and move "0000 BBBB" to w
	addlw 0xB0				; add offset
	movwf FSR
	movf	INDF, W			; Move contents at 0xB0 + BBBB to W
	movwf TEMP2				;
	;movfw TEMP1				;
	;movwf FSR				; Pointing register now points to TEMP1 data, "cccc"
	swapf TEMP2, 0			; Swap back so w holds "bbbb 0000"
	addwf TEMP1, 0				; Stored in w is now "bbbb cccc"
	return

GRABBTWICE					; grabbing "Rb + Rb+1"

	bcf STATUS, RP1
	bsf STATUS, RP0			; bank 1
	movfw INS2
	movwf TEMP1
	movfw INS2
	addlw 0x01				; add 1 to it
	movwf TEMP2				; move "XXXX bbb(b+1)"
	bcf TEMP1, 7
	bcf TEMP1, 6
	bcf TEMP1, 5
	bcf TEMP1, 4
	bcf TEMP2, 7
	bcf TEMP2, 6
	bcf TEMP2, 5
	bcf TEMP2, 4
	swapf TEMP1, 0			; swap TEMP1 and put it in w
	addwf TEMP2, 0				; w is now "bbbb bbb(b+1)"
	return
	


BANKCHECK					; Check bank select bit
	
	btfss R14, 3			; If R14 is 0XXX
		addlw 0xC0			; Move the proper offset to select Bank 0
	btfsc R14, 3			; If R14 is 1XXX
		


END