.ASECT

. = 10000

PCtr = 0
SCtr = 2
PStep = 4
Ptr = 6
UsrS = 66
SEL1 = 177716

DStep = 2000

Lines = 71

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
	BR .
M:	Load A
.ENDM
	
	MOV #1000, SP

	MOV #1270, 177664
	MOV #405, R0
	EMT 52
;	EMT 12

	MOV #100000, R0
	MOV #20000, R1
3$:	CLR (R0)+
	SOB R1, 3$

	MOV #EndL-10, LPtr
	MOV #Lines-1*400+100000, FbPtr
	MOV #4, BlCtr

	BIS #100, UsrS

	MOV #DStep, DCtr

	MOV #5, TIMSET
	CLR TIMCTL
	MOV #24, TIMCTL


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

	DEC DCtr
	BNE 5$

	MOV #DStep, DCtr
	JSR PC, DispRow
	MOV 177664, R0
	CMP R0, #1324
	BEQ 5$
	DEC R0
	BIS #1000, R0
	MOV R0, 177664

5$:	Step A, 10$
10$:	Step B, 20$
20$:	Step C, 30$
30$:	Count A, EndA, 50$, 40$
50$:	Count B, EndB, 70$, 60$
70$:	Count C, EndC, 1$, 80$
	BR 1$

DispRow::
	MOV LPtr, R0
	CMP R0, #Logo-10
	BEQ 10$
	MOV FbPtr, R1

	MOV #10, R4
1$:	MOVB (R0)+, R2
	MOV #10, R5
2$:	ROR R2
	BCS 3$
	MOVB #0, (R1)+
	BR 4$
3$:	MOVB #377, (R1)+
4$:	SOB R5, 2$
	SOB R4, 1$

	SUB #100, FbPtr
	DEC BlCtr
	BNE 10$
	MOV #4, BlCtr
	SUB #10, LPtr

10$:	RTS PC

FbPtr:: .Word 0
LPtr:: .Word 0
BlCtr:: .Word 0

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
DCtr::	.Word 0
