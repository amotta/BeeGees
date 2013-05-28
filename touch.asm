; file:		touch.asm
; author:	Lucas Fric
;		Alessandro Motta

; config
.equ	touchTop = 0
.equ	touchBot = 2
.equ	touchLeft = 1
.equ	touchRight = 3
.equ	touchSpeed = 4

.equ	touchContrDDR = DDRA
.equ	touchContrPort = PORTA

.dseg
; latest pos X
touchPosX:
	.byte	1

; latest pos Y
touchPosY:
	.byte	1

; current mode
; 0x00	read pos X
; 0xff	read pos Y
touchDir:
	.byte	1

.cseg
touchInit:
	; save a0
	push	a0

	; enable ADC
	; and set conversion speed
	OUTI	ADCSR, (1 << ADEN) + (1 << ADIE) + touchSpeed
	
	; init control port
	OUTI	touchContrDDR, 0x00
	OUTI	touchContrPort, 0x00
	
	; init memory
	clr	a0
	sts	touchPosX, a0
	sts	touchPosY, a0
	sts	touchDir, a0
	
	; init first run
	rcall	touchInitDirX
	
	; start conversion
	sbi	ADCSR, ADSC
	
	; restore a0
	pop	a0
	
	ret
	
	
; config to read pos 
; in:	none
touchInitDirX:
	; save a0
	push	a0

	; set direction
	ldi	a0, 0
	sts	touchDir, a0

	; config control port
	clr	a0
	ori	a0, (1 << touchLeft)
	ori	a0, (1 << touchRight)
	out	touchContrDDR, a0
	
	; write control port
	clr	a0
	ori	a0, (1 << touchRight)
	out	touchContrPort, a0
	
	; select A2C line
	OUTI	ADMUX, touchBot
	
	; restore a0
	pop	a0
	
	ret


; config to read pos Y
; in:	none
touchInitDirY:
	; save a0
	push	a0

	; set direction
	ldi	a0, 1
	sts	touchDir, a0

	; config control port
	clr	a0
	ori	a0, (1 << touchTop)
	ori	a0, (1 << touchBot)
	out	touchContrDDR, a0
	
	; write control port
	clr	a0
	ori	a0, (1 << touchBot)
	out	touchContrPort, a0
	
	; select A2C line
	OUTI	ADMUX, touchLeft
	
	; restore a0
	pop	a0
	
	ret
	
	
; in:	a0	ADC low
;	a1	ADC high
; out	a0	pos X
touchToPosX:
	; clear carry
	clc
	
	ROR2	a1, a0
	ROR2	a1, a0
	ROR2	a1, a0
	ROR2	a1, a0
	
	ret

	
; in:	a0	ADC low
;	a1	ADC high
; out	a0	pos Y
touchToPosY:
	; clear carry
	clc
	
	ROR2	a1, a0
	ROR2	a1, a0
	ROR2	a1, a0
	ROR2	a1, a0
	ROR2	a1, a0
	
	ret

; in:	none
touchRun:
	; save SREG
	in	_sreg, SREG

	; save regs
	push	a0
	push	a1
	push	a2
	
	; read result
	in	a0, ADCL
	in	a1, ADCH
	
	; get current dir
	lds	a2, touchDir
	
	; to posX
	sbrs	a2, 0
	rcall	touchToPosX
	
	; to posY
	sbrc	a2, 0
	rcall	touchToPosY
	
	; save pos X
	sbrs	a2, 0
	sts	touchPosX, a0
	
	; save pos Y
	sbrc	a2, 0
	sts	touchPosY, a0
	
	; set new dir
	com	a2
	sts	touchDir, a2
	
	; dir X
	sbrs	a2, 0
	rcall	touchInitDirX
	
	; dir Y
	sbrc	a2, 0
	rcall	touchInitDirY
	
	; start conversion
	sbi	ADCSR, ADSC
	
	; restore regs
	pop	a2
	pop	a1
	pop	a0
	
	; restore SREG
	out	SREG, _sreg
	
	reti