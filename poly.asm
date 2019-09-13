.TITLE ANTHEM
.ASECT

. = 10000

UsrS = 66
SEL1 = 177716

BufA = 40000
BufB = 50000
BufM = 60000

	MOV #1, R0
	EMT 52

PrepA::
	MOV #TrackA, R0
	MOV #BufA, R1
20$:
	MOV (R0)+, R2
10$:
	MOV (R0), (R1)+
	MOV #1, (R1)+
	MOV (R0), (R1)+
	MOV #0, (R1)+
	ADD (R0), R3
	SOB R2, 10$
	INC R0
	CMP #EndA, R0
	BLT 20$
	MOV R1, EBufA

PrepB::
	MOV #TrackB, R0
	MOV #BufB, R1
20$:
	MOV (R0)+, R2
10$:
	MOV (R0), (R1)+
	MOV #1, (R1)+
	MOV (R0), (R1)+
	MOV #0, (R1)+
	ADD (R0), R3
	SOB R2, 10$
	INC R0
	CMP #EndB, R0
	BLT 20$
	MOV R1, EBufB

Merge::
	MOV #BufA, R0
	MOV #BufB, R1
	MOV #BufM, R2
5$:
	CMP (R0), (R1)
	BGT 10$
	SUB (R0), (R1)
	MOV (R0)+, (R2)+
	MOV (R0)+, (R2)
	BIS 2(R1), (R2)+
	BR 20$
10$:
	SUB (R1), (R0)
	MOV (R1)+, (R2)+
	MOV (R1)+, (R2)
	BIS 2(R0), (R2)+
20$:	CMP R1, EBufB
	BEQ 30$
	CMP R0, EBufA
	BEQ 40$
	BR 5$
30$:	MOV EBufA, R3
	SUB R0, R3
	ASR R3
35$:	MOV (R0)+, (R2)+
	SOB R3, 35$
	BR 50$
40$:	MOV EBufB, R3
	SUB R1, R3
	ASR R3
45$:	MOV (R1)+, (R2)+
	SOB R3, 45$
50$:	MOV R2, EBufM

Condense::
	MOV #BufM, R0
	MOV #BufM, R1
10$:	TST (R0)
	BNE 15$
	ADD #4, R0
	CMP R0, EBufM
	BNE 10$
	BR 50$
15$:	MOV (R0)+, (R1)
	MOV (R0)+, 2(R1)
	CMP R0, EBufM
	BEQ 40$
20$:	CMP 2(R0), 2(R1)
	BNE 30$
	ADD (R0), (R1)
	ADD #4, R0
	CMP R0, EBufM
	BEQ 40$
	BR 20$
30$:	ADD #4, R1
	BR 10$
40$:	ADD #4, R1
50$:	MOV R1, EBufM

Play::
	MOV UsrS, R0
	MOV #100, R1
	XOR R0, R1
	MOV #BufM, R2
5$:
	MOV (R2)+, R3
	TST (R2)+
	BEQ 10$
	MOV R1, Sel1
	SOB R3, .
	CMP R2, EBufM
	BNE 5$
10$:	MOV R0, Sel1
	SOB R3, .
	CMP R2, EBufM
	BNE 5$

End::	HALT

EBufA::	.Word 0
EBufB::	.Word 0
EBufM:: .Word 0

TrackA::
	.Word 2000
	.Word 230
	.Word 2000
	.Word 253
	.Word 2000
	.Word 300
EndA::

TrackB::
	.Word 1000
	.Word 600
	.Word 1000
	.Word 526
	.Word 1000
	.Word 460
EndB::
