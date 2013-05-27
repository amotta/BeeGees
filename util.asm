; file:		util.asm
; author:	Lucas Fric
;		Alessandro Motta

; performs an integer division
; in:	a0	dividend
; out:	a0	quotient
;	a1	rest
utilDivTen:
	; save regs
	push	b0
	push	c0
	push	d0
	
	; load divisor
	ldi	b0, 10
	
	; call div
	rcall	div11
	
	; prepare output
	mov	a0, c0
	mov	a1, d0
	
	; restore regs
	pop	d0
	pop	c0
	pop	b0

	ret