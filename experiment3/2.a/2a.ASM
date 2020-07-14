;--------------------------------------------------------------------------
;
;              Build this with the "Source" menu using
;                     "Build All" option
;
;--------------------------------------------------------------------------
;
;                           ʵ��������ͨ�ÿ��
;
;--------------------------------------------------------------------------
; ���ܣ� ������					                            				   |
; ��д����Ƕ��ʽϵͳԭ����ʵ�顷�γ���                   				   |
; �汾��3.5
; �޶���B
;--------------------------------------------------------------------------


		DOSSEG
		.MODEL	SMALL		; �趨8086������ʹ��Small model
		.8086				; �趨����8086���ָ�

;-----------------------------------------------------------
;	�����ջ��                                             |
;-----------------------------------------------------------
	.stack 100h				; ����256�ֽ������Ķ�ջ

;-------------------------------------------------------------------------
;	���Ŷ���                                                              |
;-------------------------------------------------------------------------
;
;
; 8253оƬ�˿ڵ�ַ ��Port Address):
L8253T0			EQU	301H			; Timer0's port number in I/O space
L8253T1			EQU 	303H			; Timer1's port number in I/O space
L8253T2			EQU 	305H			; Timer2's port number in I/O space
L8253CS			EQU 	307H			; 8253 Control Register's port number in I/O space
;
; 8255оƬ�˿ڵ�ַ ��Port Address):
L8255PA			EQU	321H			; Port A's port number in I/O space
L8255PB			EQU 	323H			; Port B's port number in I/O space
L8255PC			EQU 	325H			; Port C's port number in I/O space
L8255CS			EQU 	327H			; 8255 Control Register's port number in I/O space
;
;  �ж�ʸ���Ŷ���
IRQNum			EQU	2CH			; �ж�ʸ����,Ҫ����ѧ�ż���õ�����´˶��塣

Patch_Protues	EQU	IN AL, 0	;	Simulation Patch for Proteus, please ignore this line

;=======================================================================
; �궨��
;=======================================================================

; �޲�Proteus�����BUG���μ�������е�ʹ��˵��
    WaitForHWInt MACRO INTNum		; INTNum is the HW INT number
		MOV AL, INTNum   			;
		OUT 0,AL					;
		STI
		CLI
    ENDM



;-----------------------------------------------------------
;	�������ݶ�                                             |
;-----------------------------------------------------------
		.data					; �������ݶ�;

DelayShort	dw	40			; ����ʱ����	
DelayLong	dw	4000			; ����ʱ����


; SEGTAB is the code for displaying "0-F", and some of the codes may not be correct. Find and correct the errors.
	SEGTAB  DB 3FH	; 7-Segment Tube
		DB 06H	;
		DB 5BH	;            a a a
		DB 4FH	;         f         b
		DB 66H	;         f         b
		DB 6DH	;         f         b
		DB 7DH	;            g g g 
		DB 07H	;         e         c
		DB 7FH	;         e         c
		DB 6FH	;         e         c
        	DB 77H	;            d d d     h h h
		DB 7CH	; ----------------------------------
		DB 39H	;       b7 b6 b5 b4 b3 b2 b1 b0
		DB 5EH	;       DP  g  f  e  d  c  b  a
		DB 79H	;
		DB 71H	;

;-----------------------------------------------------------
;	��������                                             |
;-----------------------------------------------------------
		.code						; Code segment definition
		.startup					; Entrance of this program
;------------------------------------------------------------------------
		Patch_Protues					; Simulation Patch for Proteus,
								; Please ignore the above code line.
;------------------------------------------------------------------------

START:								; Modify the following codes accordingly
								; 
		CLI						; Disable interrupts
		MOV AX, @DATA					;
		MOV DS, AX					; Initialize DS

		CALL INIT8255					; Initialize 8255 
		CALL INIT8253					; Initialize 8253


Display_Again:
		CALL DISPLAY8255				; Procedure DISPLAY8255 is used to contrl 7-segment tubes
		; Put you code here


;===================================================================================
; Attention:
; The following codes is a Patching for Proteus 8086 Hardware Simulation Bug.
; Use these codes in the case you want the 8086 to halt and waiting for HW INT only! 
; You can treat it as if it doesn't exist. 
;
; If you need to use HW INT, please uncomment it, or
; Don't modify it, leave it here just as it is.
;		WaitForHWInt IRQNum				
;====================================================================================
		JMP	Display_Again

		HLT						; 
;=====================================================================================





;--------------------------------------------
;                                           |
; INIT 8255 					            |
;                                           |
;--------------------------------------------
INIT8255 PROC

		MOV AL,10001001B; Init 8255 in Mode x,	L8255PA xPUT, L8255PB xPUT, L8255PCU xPUT, L8255PCL xPUT
		MOV DX, L8255CS
		OUT DX, AL
		


		RET
INIT8255 ENDP

;--------------------------------------------
;                                           |
; INIT 8253 					            |
;                                           |
;--------------------------------------------
INIT8253 PROC

; Set the mode and the initial count for Timer0


; Set the mode and the initial count for Timer1


; Set the mode and the initial count for Timer2


		RET
INIT8253 ENDP

;--------------------------------------------
;                                           |
; DISPLAY  STUDENTS ID				 		|
;                                           |
;--------------------------------------------

DISPLAY8255 PROC
	       MOV AL,10001001B; Init 8255 in Mode x,	L8255PA xPUT, L8255PB xPUT, L8255PCU xPUT, L8255PCL xPUT
	       MOV DX, L8255CS
	       OUT DX, AL
	       MOV DX, L8255PC
	       IN  AX, DX
	       AND AX,01H
	       MOV CX, 6H
	       SHL AX, CL
	       MOV BX, AX
	       MOV AL, 10000000B
	       MOV DX, L8255CS
	       OUT DX, AL
	       MOV AL, BL
	       MOV DX, L8255PC
	       OUT DX, AL
CALL DELAY

		RET
	
DISPLAY8255 ENDP


;--------------------------------------------------------------
;                                                             |                                                            |
; Function��DELAY FUNCTION                                    | 
; Input��None												  |
; Output: None                                                |
;--------------------------------------------------------------

DELAY 	PROC
    	PUSH CX
    	MOV CX, DelayShort
D1: 	LOOP D1
    	POP CX
    	RET
DELAY 	ENDP

;-------------------------------------------------------------
;                                                             |                                                            |
; Function��INTERRUPT Vector Table INIT						  |
; Input: BL = Interrupt number								  |
; Output: None			                                	  |
;                                                             |
;-------------------------------------------------------------	
INT_INIT	PROC FAR			; The code is not complete and you should finalize the procedure
		CLI				; Disable interrupt
		MOV AX, 0
		MOV ES, AX			; To set up the interrupt vector table
; Put your code here
; Hint: you can use the directives such as SEGMENT,OFFSET to get the segment value and the offset of a label


						; Do not to forget to return back from a procedure		
INT_INIT	ENDP

		
;--------------------------------------------------------------
;                                                             |                                                            |
; FUNCTION: INTERRUPT SERVICE  Routine ��ISR��				  | 
; Input::                                                     |
; Output:                                                     |
;                                                             |
;--------------------------------------------------------------	
		
MYIRQ 	PROC FAR				; The code is not complete and you should finalize the procedure
; Put your code here

						; Do not forget to return back from a ISR
MYIRQ 	ENDP

	END					