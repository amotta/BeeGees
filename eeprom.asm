; file:		eeprom.asm
; author:	Lucas Fric
;		Alessandro Motta
; original:	R. Holzer

; in:	xh:xl	EEPROM address
;	a0	EEPROM data byte to store
eepromStore:
	; wait for EEWE
	sbic	EECR, EEWE
	rjmp	PC - 1
	
	; set address
	out	EEARL, xl
	out	EEARH, xh
	out	EEDR, a0
	
	; with interrupts
	brie	eepromStoreCli
	
	; without interrupts
	sbi	EECR, EEMWE
	sbi	EECR, EEWE
	
	ret

eepromStoreCli:
	cli
	sbi	EECR, EEMWE
	sbi	EECR, EEWE
	sei
	
	ret
	
; in:	xh:xl	EEPROM address
; out	a0	EEPROM data byte to load
eepromLoad:
	; wait for EEWE
	sbic	EECR, EEWE
	rjmp	PC - 1
	
	; set address
	out	EEARL, xl
	out	EEARH, xh
	
	; read
	sbi	EECR, EERE
	in	a0, EEDR
	
	ret