.TITLE ANTHEM
.ASECT

. = 10000

UsrS = 66
SEL1 = 177716

TIMCNT = 177706
TIMSET = 177710
TIMCTL = 177712

Ptr = 0
End = 2
Rem = 4
Per = 6
Ctr = 10
Sta = 12

	MOV #1000, SP

	MOV #TrackA, A+Ptr
	MOV #EndA, A+End
	MOV #TrackB, B+Ptr
	MOV #EndB, B+End
	MOV UsrS, A+Sta
	MOV UsrS, B+Sta
	CLR A+Rem
	CLR A+Ctr
	CLR B+Rem
	CLR B+Ctr

	CLR TIMSET
	CLR TIMCTL
	MOV #22, TIMCTL

5$:
;	MOV #101, R0
;	EMT 16
;	MOV #A, R1
;	JSR PC, OscState
;	MOV #102, R0
;	EMT 16
;	MOV #B, R1
;	JSR PC, OscState

	MOV B+Sta, R3
	BIS B+Sta, R3
	MOV A+Rem, R0
	MOV B+Rem, R1
	CMP R0, R1
	BGT 10$
	MOV R0, R2
	BR 20$
10$:	MOV R1, R2
20$:	SUB R2, A+Rem
	BNE 30$
	MOV #A, R0
	JSR PC, Osc
30$:	SUB R2, B+Rem
	BNE 40$
	MOV #B, R0
	JSR PC, Osc
40$:	
	MOV R3, SEL1
	MOV TIMCNT, TIMSET
	ADD R2, TIMSET
	CLR TIMCTL
	MOV #30, TIMCTL
1$:	BIT #20, TIMCTL
	BNE 1$
	CLR TIMSET
	MOV #22, TIMCTL
	BR 5$

Osc::
	TST Ctr(R0)
	BNE 10$
	CMP Ptr(R0), End(R0)
	BEQ 20$
	MOV Ptr(R0), R1
	MOV (R1)+, Ctr(R0)
	MOV (R1)+, Per(R0)
	MOV R1, Ptr(R0)
10$:	MOV #100, R1
	XOR R1, Sta(R0)
	DEC Ctr(R0)
	MOV Per(R0), Rem(R0)
	RTS PC

20$:	CMP R0, #A
	BNE 30$
	MOV #TrackA, Ptr(R0)
	BR Osc
30$:	MOV #TrackB, Ptr(R0)
	BR Osc

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
	.Word 1000
EndA::
TrackB::
	.Word 1000
	.Word 10
	.Word 1000
	.Word 20
	.Word 1000
	.Word 30
	.Word 1000
	.Word 40
	.Word 1000
	.Word 50
EndB::

;.include polydata.asm
