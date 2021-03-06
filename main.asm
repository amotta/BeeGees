; file:		main.asm
; author:	Lucas Fric
;		Alessandro Motta

.include	"m103def.inc"
.include	"stk300def.inc"
.include	"macros.inc"

; interrupt vector
.org	0
	jmp	reset

.org	ACIaddr
 	jmp	touchRun

; in:	none
reset:
	; load stack pointer
	LDSP	RAMEND
	
	; make port D input
	OUTI	DDRD, 0x00
	
	; enable interrupts
	sei
	
	; init SRAM
	rcall	sramInit

	; init communication
	rcall	comInit

	; init touch pad
	rcall	touchInit
	
	; clear b0
	clr	b0
	
	; continue with main
	rjmp	main

; include modules
.include	"com.asm"
.include	"eeprom.asm"
.include	"vis.asm"
.include	"touch.asm"
.include	"sram.asm"
.include	"math.asm"
.include	"util.asm"

; data
.dseg
color:
	.byte 1
	
image:
	.byte 2048

; code
.cseg

txtMenu:
	.db "0 Draw, 1 Color, 2 Save, 3 Load", 0
	
txtColor:
	.db " 0 ", 0x1b, 0x5b, "41m"
	.db " 1 ", 0x1b, 0x5b, "42m"
	.db " 2 ", 0x1b, 0x5b, "43m"
	.db " 3 ", 0x1b, 0x5b, "44m"
	.db " 4 ", 0x1b, 0x5b, "45m"
	.db " 5 ", 0x1b, 0x5b, "46m"
	.db " 6 ", 0x1b, 0x5b, "47m"
	.db " 7 ", 0

txtLoad:
	.db "Load from slot [0 ... 3]", 0, 0
	
txtLoading:
	.db "Loading...", 0
	
txtSave:
	.db "Save to slot [0 ... 3]", 0, 0

txtSaving:
	.db "Saving...", 0

main:
	lds	a0, touchPosX
	lds	a1, touchPosY
	rcall	visSetPos
	
bouton0:
	sbic	PIND, 0			;dessiner / choix 0
	rjmp	bouton1
	
	andi	b0, 0xf0			;entrer dans bouton0 (pour si enregistrer,charger, couleur) choix 0

	sbrc	b0, 4
	rjmp	couleur

	sbrc	b0, 5
	rjmp	save

	sbrc	b0, 6
	rjmp	load

	lds	a0, touchPosX
	lds	a1, touchPosY
	lds	a2, color
	rcall	draw
	
	rjmp	fin_bouton


bouton1: 				;couleur / choix 1
	sbic	PIND, 1			
	rjmp	bouton2
	
	; skip on hold
	sbrs	b0, 7
	rjmp	fin_bouton
	
	andi	b0, 0xf0			
	ori	b0, 0x01			;flag coix 1

	sbrc	b0, 4
	rjmp	couleur

	sbrc	b0, 5
	rjmp	save

	sbrc	b0, 6
	rjmp	load
	
	ori	b0, 0x10		;flag couleur activ�

	LDIZ	txtColor << 1
	rcall	visStatus
	
	rjmp	fin_bouton


bouton2: 				;enregistrer / choix 2
	sbic	PIND, 2			
	rjmp	bouton3
	
	; skip on hold
	sbrs	b0, 7
	rjmp	fin_bouton
	
	andi	b0, 0xf0
	ori 	b0, 0x02			

	sbrc	b0, 4
	rjmp	couleur

	sbrc	b0, 5
	rjmp	save

	sbrc	b0, 6
	rjmp	load
	
	; save flag
	ori	b0, 0x20
	
	; show save
	LDIZ	txtSave << 1
	rcall	visStatus

	rjmp	fin_bouton


bouton3: 				;charger / choix 3
	sbic	PIND, 3			
	rjmp	bouton4
	
	; skip on hold
	sbrs	b0, 7
	rjmp	fin_bouton
	
	andi	b0, 0xf0
	ori 	b0, 0x03			;flag choix 3

	sbrc	b0, 4
	rjmp	couleur

	sbrc	b0, 5
	rjmp	save

	sbrc	b0, 6
	rjmp	load
	
	ori	b0, 0x40 ;flag charger activ�
	
	; show load
	LDIZ	txtLoad << 1
	rcall	visStatus

	rjmp	fin_bouton	


bouton4: 				;choix 4 
	sbic	PIND, 4			
	rjmp	bouton5
	
	; skip on hold
	sbrs	b0, 7
	rjmp	fin_bouton
	
	andi	b0, 0xf0
	ori	b0, 0x04			

	sbrc	b0, 4
	rjmp	couleur

	rjmp	fin_bouton	


bouton5: 				;choix 5 
	sbic	PIND, 5			
	rjmp	bouton6
	
	; skip on hold
	sbrs	b0, 7
	rjmp	fin_bouton
	
	andi	b0, 0xf0
	ori 	b0, 0x05
			
	sbrc	b0, 4
	rjmp	couleur

	rjmp	fin_bouton	


bouton6: 				;choix 6 
	sbic	PIND, 6			
	rjmp	bouton7
	
	; skip on hold
	sbrs	b0, 7
	rjmp	fin_bouton
	
	andi	b0, 0xf0
	ori	b0, 0x06
			
	sbrc	b0, 4
	rjmp	couleur

	rjmp	fin_bouton	


bouton7: 				;choix 7 
	sbic	PIND, 7			
	rjmp	aucun_bouton
	
	; skip on hold
	sbrs	b0, 7
	rjmp	fin_bouton
	
	andi	b0, 0xf0
	ori	b0, 0x07
			
	sbrc	b0, 4
	rjmp	couleur

	rjmp	fin_bouton	
	
aucun_bouton:
	; aucun bouton appuy�
	sbr	b0, (1 << 7)
	rjmp	main


fin_bouton:
	; bouton appuy�
	cbr	b0, (1 << 7)
	rjmp	main
	
	
couleur:
	andi	b0, 0x0f			;flags (couleur, enregistre, charge) d�sactiv�

	; decode color
	mov	a0, b0
	andi	a0, 0x0f
	
	; save in SRAM
	sts	color, a0
	
	; display
	rcall	visSetColor
	
	LDIZ	txtMenu << 1
	rcall	visStatus

	rjmp	fin_bouton


; in:	a0	pos X
;	a1	pos Y
;	a2	color
draw:
	; save to SRAM
	rcall	sramSave
	
	; set position
	rcall	visSetPos
	rcall	visDraw
	
	ret


; Saves image form SRAM to EEPROM
; in:	none
save:
	; show saving
	LDIZ	txtSaving << 1
	rcall	visStatus

	; set b0 to selected EEPROM slot
	andi	b0, 0x0f
	
	; set x to b0 * 2^10
	clr	xl
	mov	xh, b0
	lsl	xh
	lsl	xh
	
	; a2 points to the next image in EEPROM
	; set a2 to high((b0 + 1) * 2^10)
	mov	a2, b0
	inc	a2
	lsl	a2
	lsl	a2
	
	; set y to image in SRAM
	ldi	yl, low(image) 
	ldi	yh, high(image)

; 1024 pixels
saveFor:
	; encode pixel
	ld	a0, y+
	andi	a0, 0x07
	
	ld	a1, y+
	andi	a1, 0x07
	swap	a1
	
	or	a0, a1
	
	; save code
	rcall	eepromStore
	
	; go to next byte in EEPROM
	adiw	xl, 1			;incrementation

	; are we there yet?
	cp	xh, a2
	breq	saveEnd
	
	; continue
	rjmp	saveFor
	
saveEnd:
	LDIZ	txtMenu << 1
	rcall	visStatus

	rjmp	fin_bouton


; Reads an image from EEPROM to SRAM
; in	b0	EEPROM slot
load:
	; show loading
	LDIZ	txtLoading << 1
	rcall	visStatus

	andi	b0, 0x0f			;flags (couleur, enregistre, charge) d�sactiv�
	
	; set x to b0 * 2^10
	clr	xl
	mov	xh, b0
	lsl	xh
	lsl	xh
	
	; set a2 to high(b0 * 2^10)
	mov	a2, b0
	inc	a2
	lsl	a2
	lsl	a2
	
	; set y to image in SRAM
	ldi	yl, low(image) 
	ldi	yh, high(image)
	
	; set cursor
	ldi	a0, 1
	ldi	a1, 1
	rcall	visSetPos
	
;1024 pixels
loadFor:	
	rcall	eepromLoad
	
	; decode
	mov	a1, a0
	swap	a1
	andi	a0, 0x07
	andi	a1, 0x07
	
	; save a0 to SRAM
	st	y+, a0
	
	; display pixel
	rcall	visSetColor
	rcall	visDraw
	
	; save a1 to SRAM
	st	y+, a1
	
	mov	a0, a1
	rcall	visSetColor
	rcall	visDraw
	
	; go to next byte in EEPROM
	adiw	xl, 1

	; are we there yet?
	cp	xh, a2
	breq	loadEnd
	
	; continue
	rjmp	loadFor

loadEnd:
	; show done
	LDIZ	txtMenu << 1
	rcall	visStatus
	
	jmp	fin_bouton
	