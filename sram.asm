; file:		sram.asm
; author:	Lucas Fric
;		Alessandro Motta

; in:	none
sramInit:
	; disable external SRAM
	; cbi	MCUCR, SRE

	; clear image
	rcall	sramClear
	
	ret

; in:	none
sramClear:
	; save
	push	a0

	; set y to start of
	ldi	yl, low(image)
	ldi	yh, high(image)
	
	; set z to end of image
	ldi	zl, low(2048)
	ldi	zh, high(2048)
	add	zl, yl
	adc	zh, yh

	ldi	a0, 0
		
sramClearFor:
	; clear
	st	y+, a0
	
	cp	yl, zl
	brne	sramClearFor
	
	cp	yh, zh
	brne	sramClearFor
	
	; restore
	pop	a0
	
	ret
	

; in:	a0	pos X
;	a1	pos Y
;	a2	color
sramSave:
	; save regs
	push	a0
	push	a1
	
	; offset X
	tst	a0
	breq	PC + 2
	dec	a0
	
	; offset Y
	tst	a1
	breq	PC + 2
	dec	a1

	ldi	yl, low(image) 
	ldi	yh, high(image)

	add	yl, a0
	brcc	PC + 2
	inc	yh

	; copy a1 to a0
	mov	a0, a1
	clr	a1
	
	; set a1:a0 to a0 * 2^6
	LSL2	a1, a0
	LSL2	a1, a0
	LSL2	a1, a0
	LSL2	a1, a0
	LSL2	a1, a0
	LSL2	a1, a0

	add	yl, a0
	adc	yh, a1
	
	; store color to SRAM
	st	y, a2
	
	; restore regs
	pop	a1
	pop	a0

	ret