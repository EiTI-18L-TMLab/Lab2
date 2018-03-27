; Licznik 4-bit, kod NKB, ładowanie, zliczanie w dół
;
; Wykorzystanie rejestrów: 
;	B - zawiera wartość licznka, 
;	C - licznik debounce, 
;	D - ilość cykli debounce
;	E - stan układu licznika, 1 dla obsługi zbocza narastającego, 0 dla obsługi zbocza opadającego;
;
; Podłączenie przycisków: 
;	CLK - bit 6
;	!LD - bit 5 ( jednocześnie podłączony do !INT )
;	DANE -bity <0..3>
;
org 1800h
START:
	LD SP, 0x1FFF ; Ustawienie wskaźnika stosu
	jr MAIN 
ds 0x1838-$,0 ; Umieszczenie procedury przerwania pod adresem 0x38
INTERRUPT: 		; obsługa przerwania od przycisku !LD
	PUSH AF 	; Zapisanie na stosie rejestrów A i F
	IN A, (1) 	; wczytanie danych do załadowania
	AND 0Fh 	; wybranie istotnych danych
	LD B, A		; załadowanie licznika
	OUT (1), A	; odświeżenie LED
	POP AF		; przywrócenie stosu i powrót z przerwania
	EI
	RET
ds 0x1860-$,0 ;org 1860h
MAIN:
	IN A, (1) 	; inicjacja wartości licznika
	AND 0Fh		; wybranie istotnych danych
	LD B, A		; wpisanie początkowej wartości do licznika
	OUT (1), A	; odświeżenie licznika
	LD D, 255 	; ilość cykli debounce
	IM 1
	EI	
	LD C, D 	; ustawienie licznika debounce
	LD E, 0 	; wybrana obsługa zbocza opadającego
MAIN_LOOP: 		; początek głównej pętli

	; początek obsługi licznika
		LD A, E
		AND 0xFF	; odświeżenie stanu flag
		JR NZ, LOOP_POSITIVE ; wybranie obsługi konkretnego zbocza
	LOOP_NEGATIVE:	; obsługa zbocza opadającego
		IN A, (1)
		BIT 6, A 	; stan przycisku CLK
		JR Z, IF_1
		LD C, D 	; jeśli przycisk niewciśnięty, załaduj licznik debounce
	IF_1:
		JR NZ, IF_2
		DEC C 		; jeśli przycisk wciśnięty, dekrementuj licznik debounce
	IF_2:
		LD A, C		; odświeżenie stanu flag
		AND 0xFF
		JR NZ, COUNTER_END ; jeśli licznik debounce niezerowy, koniec obsługi
		DEC B		; wykryto poprawne zbocze opadające, akcja licznika
		DI			; sekcja krytyczna
		LD A, B		; 
		AND 0Fh
		OUT (1), A	; odświeżenie LED
		EI			; koniec sekcji krytycznej
		LD E, 1		; wybranie obsługi zbocza narastającego
		JR COUNTER_END ; skok na koniec obsługi licznika
	LOOP_POSITIVE:	; obsługa zbocza narastającego
		IN A, (1)
		BIT 6, A 	; stan przycisku CLK
		JR NZ, IF_3
		LD C, D		; jeśli przycisk wciśnięty, załaduj licznik debounce
	IF_3:
		JR Z, IF_4
		DEC C		; jeśli przycisk niewciśnięty, dekrementuj licznik debounce
	IF_4:
		LD A, C		; odświeżenie stanu flag
		AND 0xFF
		JR NZ, COUNTER_END ; jeśli licznik debounce niezerowy, koniec obsługi
		LD E, 0
	COUNTER_END:	; koniec obsługi licznika

	; dalsze operacje...	

JR MAIN_LOOP ; powrót do początku głównej pętli