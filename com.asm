; file:		com.asm
; author:	Lucas Fric
;		Alessandro Motta

; config
.equ	baud = 19200
.equ	ubbr = clock / (16 * baud) - 1

; in:	none
comInit:
	; set baud rate
	OUTI	UBRR, ubbr

	; TX is output
	OUTI	DDRE, (1 << 1)
	
	; enable TX
	OUTI	UCR, (1 << TXEN)
	
	ret

; in:	a0	byte to send
comSendByte:
	; wait until all data has been sent
	sbis	USR, UDRE
	rjmp	comSendByte
	
	; write data to UART data register
	out	UDR, a0
	
	ret
