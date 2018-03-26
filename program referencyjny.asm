org 1800h
START:
	jr GLOWNA
	ds 0x1838-$,0
	;org 1838h
INTERRUPT:
	LD D, 15
	LD A, D
	OUT (01),A
	IN A, (01)
	BIT 0, A
	LD E, 0
	JR NZ, DALEJ
	LD E, 1
DALEJ:
	EI
	RETI
	ds 0x1860-$,0
	;org 1860h
GLOWNA:
	IM 1
	EI
	LD D, 15
	LD E, 0
PETLA:
	LD A, D
	OUT (01h), A
	IN A, (01)
	BIT 0, A
	jr Z, PETLA
	LD H, 0xF0 ;licznik petli
	LD B, 128
PETLA_1:
	IN A, (01)
	BIT 0x0, A
	JR NZ, PETLA_1
	DEC B
	JR Z, DEKREMENTUJ
	DEC H
	JR NZ, PETLA_1
	JP PETLA
DEKREMENTUJ:
	BIT 0, E
	LD E, 0
	JR NZ, PETLA
	DEC D
	LD A, D
	JR NZ, PETLA
	LD D, 15
	JP PETLA