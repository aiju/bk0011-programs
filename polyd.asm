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

	BIS #100, UsrS

	MOV #5, TIMSET
	CLR TIMCTL
	MOV #24, TIMCTL

	CLR R3

Main::

	MOV #TrackA, R1
	MOV (R1)+, A+SCtr
	MOV (R1)+, A+PStep
	MOV A+PStep, A+PCtr
	MOV R1, A+Ptr

	MOV #TrackB, R1
	MOV (R1)+, B+SCtr
	MOV (R1)+, B+PStep
	MOV B+PStep, B+PCtr
	MOV R1, B+Ptr

	MOV UsrS, R0

1$:	TSTB TIMCTL
	BPL 1$
	MOV #24, TIMCTL

	MOV R0, SEL1
	MOV UsrS, R0

	SUB #100, A+PCtr
	BCC 10$
	BIC #100, R0
	ADD A+PStep, A+PCtr

10$:	SUB #100, B+PCtr
	BCC 20$
	BIC #100, R0
	ADD B+PStep, B+PCtr

20$:	DEC A+SCtr
	BNE 40$
	MOV A+Ptr, R1
	CMP R1, #EndA
	BNE 30$
	HALT
30$:	MOV (R1)+, A+SCtr
	MOV (R1)+, A+PStep
	MOV A+PStep, A+PCtr
	MOV R1, A+Ptr

40$:	DEC B+SCtr
	BNE 1$
	MOV B+Ptr, R1
	CMP R1, #EndB
	BNE 50$
	HALT
50$:	MOV (R1)+, B+SCtr
	MOV (R1)+, B+PStep
	MOV B+PStep, B+PCtr
	MOV R1, B+Ptr
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

.include polydata.asm
