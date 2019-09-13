.TITLE ANTHEM
.ASECT

. = 10000

UsrS = 66
SEL1 = 177716

TIMCNT = 177706
TIMSET = 177710
TIMCTL = 177712

Ptr = 0
Rem = 2
Per = 4
Ctr = 6

.MACRO Toggle
	MOV R4, SEL1
	NOP
	MOV R5, SEL1
.ENDM

.MACRO FakeToggle
	MOV R5, SEL1
	MOV #10, R2
	SOB R2, .
	MOV R5, SEL1
.ENDM

.MACRO DoOsc, A, T, X
	MOV A+Per, A+Rem
	DEC A+Ctr
	BNE X
	JSR PC, T
.ENDM

	MOV #1000, SP

	MOV UsrS, R4
	BIC #100, R4
	MOV R4, R5
	BIS #100, R5

	MOV #TrackA, A+Ptr
	MOV #TrackB, B+Ptr
	JSR PC, AdvA
	JSR PC, AdvB

1$:	Toggle
	MOV A+Rem, R0
	MOV B+Rem, R1
	CMP R0, R1
	BGT 20$
	BLT 10$

	;SOB R0, .
	FakeToggle

	DoOsc A, AdvA, 5$
5$:	DoOsc B, AdvB, 1$
	BR 1$

10$:	SUB R0, B+Rem
	;SOB R0, .
	FakeToggle
	DoOsc A, AdvA, 1$
	BR 1$

20$:	SUB R1, A+Rem
	;SOB R1, .
	FakeToggle
	DoOsc B, AdvB, 1$
	BR 1$

.MACRO Adv, A, E, T
	MOV Ptr+A, R1
	CMP R1, #E
	BNE 15$
	MOV #T, R1
15$:	MOV (R1)+, A+Ctr
	MOV (R1)+, A+Per
	MOV A+Per, A+Rem
	MOV R1, Ptr+A
	RTS PC
.ENDM

AdvA::
	Adv A, EndA, TrackA

AdvB::
	Adv B, EndB, TrackB

OscState::
	MOV #6, R2
10$:	MOV (R1)+, R0
	JSR PC, PutOct
	MOV #040, R0
	EMT 16
	SOB R2, 10$
	MOV #015, R0
	EMT 16
	MOV #012, R0
	EMT 16
	RTS PC


PutOct::
	MOV R0, -(SP)
	BIT #177770, R0
	BEQ 10$
	CLC
	ROR R0
	ASR R0
	ASR R0
	JSR PC, PutOct
	MOV (SP), R0
10$:	BIC #177770, R0
	BIS #60, R0
	EMT 16
	MOV (SP)+, R0
	RTS PC

A::
	.Word 0
	.Word 0
	.Word 0
	.Word 0
	.Word 0
	.Word 0
B::
	.Word 0
	.Word 0
	.Word 0
	.Word 0
	.Word 0
	.Word 0

TrackA::
	.Word 1000
	.Word 100
EndA::
TrackB::
	.Word 1000
	.Word 62
EndB::

;.include polydata.asm
