; file:		vis.asm
; author:	Lucas Fric
;		Alessandro Motta

; config
.equ	asciiESC = 0x1b
.equ	asciiBra = 0x5b
.equ	asciiSemi = 0x3b

; in:	z	pointer on string FLASH
visPrintString:
	; save r0
	push	a0
	push	r0

visPrintStringLoop:
	; load char in r0
	lpm
	
	; copy char to a0
	mov	a0, r0
	
	; check for NULL
	tst	r0
	breq	visPrintStringEnd
	
	; send byte
	rcall	comSendByte
	
	; increment z
	adiw	zl, 1
	
	; continue
	rjmp	visPrintStringLoop

visPrintStringEnd:
	; restore r0
	pop	r0
	pop	a0
	
	ret

; in:	a0	number
visPrintDec:
	; save a1
	push	a0
	push	a1
	
	; decompose
	rcall	utilDivTen
	push	a1
	
	rcall	utilDivTen
	push	a1
	
	rcall	utilDivTen
	push	a1
	
	; to ASCII
	ldi	a1, '0'
	
	pop	a0
	add	a0, a1
	rcall	comSendByte
	
	pop	a0
	add	a0, a1
	rcall	comSendByte
	
	pop	a0
	add	a0, a1
	rcall	comSendByte
	
	; restore a1
	pop	a1
	pop	a0
	
	ret

; in:	a0	pos X
;	a1	pos Y
visSetPos:
	; save
	push	a0
	push	a2
	
	; save a0
	mov	a2, a0
	
	; send CSI
	rcall	visSendCSI
	
	mov	a0, a1
	rcall	visPrintDec
	
	ldi	a0, asciiSemi
	rcall	comSendByte
	
	mov	a0, a2
	rcall	visPrintDec
	
	ldi	a0, 'f'
	rcall	comSendByte
	
	; restore
	pop	a2
	pop	a0
	
	ret

; in:	a0	color code
visSetColor:
	; save a1
	push	a1

	; save a0
	mov	a1, a0

	; send CSI
	rcall	visSendCSI
	
	; send '4'
	ldi	a0, '4'
	rcall	comSendByte
	
	; color code to ascii code
	ldi	a0, '0'
	add	a0, a1
	rcall	comSendByte
	
	ldi	a0, 'm'
	rcall	comSendByte
	
	; restore a0
	mov	a0, a1
	
	; restore a1
	pop	a1
	
	ret
	
; in:	none
visDraw:
	; save
	push	a0
	
	ldi	a0, ' '
	rcall	comSendByte
	
	; restore
	pop	a0
	
	ret	
	
; in:	none
; mod:	a0
visSendCSI:
	; save a0
	push	a0

	; send ESC
	ldi	a0, asciiESC
	rcall	comSendByte
	
	; send left bracket
	ldi	a0, asciiBra
	rcall	comSendByte
	
	; restore a0
	pop	a0
	
	ret