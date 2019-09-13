.TITLE ANTHEM
.Asect

. = 10000

	MOV #1000, SP

	MOV #1331, 177664
	MOV #5, R0
	EMT 52
;	EMT 12

Clear::
	MOV #40000, R0
	MOV #20000, R1
3$:	CLR (R0)+
	SOB R1, 3$

	MOV #Logo, LPtr
	MOV #40000, FbPtr
	MOV #4, BlCtr

Play::
	MOV #Track, TPtr
10$:
	MOV TPtr, R0
	MOV (R0)+, -(SP)
	MOV (R0)+, -(SP)
	MOV R0, TPtr
	EMT 124
	ADD #4, SP

	JSR PC, DispRow
	CMP 177664, #1254
	BEQ 2$
	INC 177664

2$:	CMP TPtr, #EndTr
	BNE 10$

	BR .

DispRow::
	MOV LPtr, R0
	CMP R0, #EndL
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

	MOV R1, FbPtr
	DEC BlCtr
	BNE 10$
	MOV #4, BlCtr
	ADD #10, LPtr

10$:	RTS PC

TPtr:: .Word 0
FbPtr:: .Word 0
LPtr:: .Word 0
BlCtr:: .Word 0

Track::
	.INCLUDE monodata.asm
EndTr::

Logo::
	.INCLUDE logo.asm
EndL::
