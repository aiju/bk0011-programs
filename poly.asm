.ASECT

. = 10000

PCtr = 0
SCtr = 2
PStep = 4
Ptr = 6
UsrS = 66
SEL1 = 177716

TIMSET = 177706
TIMCNT = 177710
TIMCTL = 177712

.MACRO Load A
	MOV (R1)+, A+SCtr
	MOV (R1)+, A+PStep
	MOV A+PStep, A+PCtr
	MOV R1, A+Ptr
.ENDM

.MACRO Step A, L
	SUB #100, A+PCtr
	BCC L
	BIC #100, R0
	ADD A+PStep, A+PCtr
.ENDM

.MACRO Count A, E, L, M
	DEC A+SCtr
	BNE L
	MOV A+Ptr, R1
	CMP R1, #E
	BNE M
	HALT
M:	Load A
.ENDM
	

	BIS #100, UsrS

	MOV #5, TIMSET
	CLR TIMCTL
	MOV #24, TIMCTL

	CLR R3

Main::
	MOV #TrackA, R1
	Load A

	MOV #TrackB, R1
	Load B

	MOV #TrackC, R1
	Load C

	MOV UsrS, R0

1$:	TSTB TIMCTL
	BPL 1$
	MOV #24, TIMCTL

	MOV R0, SEL1
	MOV UsrS, R0

	Step A, 10$
10$:	Step B, 20$
20$:	Step C, 30$
30$:	Count A, EndA, 50$, 40$
50$:	Count B, EndB, 70$, 60$
70$:	Count C, EndC, 1$, 80$
	BR 1$

A::
	.Word 0
	.Word 0
	.Word 0
	.Word 0
B::
	.Word 0
	.Word 0
	.Word 0
	.Word 0
C::
	.Word 0
	.Word 0
	.Word 0
	.Word 0

.include polydata.asm
