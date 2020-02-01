INCLUDE 'emu8086.inc'

CALL PTHIS
DB "the number's base: ", 0
CALL SCAN_NUM
MOV A, CL

CALL PTHIS
DB 10, 13, "the number: ", 0
; SCAN input

LEA BP, input
MOV AH, 01h

SCN:
INT 21h
CMP AL, 13
JE NXT
MOV [BP], AL
INC BP
JMP SCN

NXT:
INC BP
MOV [BP], 0


;
CALL PTHIS
DB 10, 13, "the new base: ", 0
CALL SCAN_NUM
MOV B, CL         

CALL STRLEN  

; PROCESS THE CHARACTERS AND TURN INTO AN ARRAY OF NUMBERS (A -> 10 ...)
MOV CX, LEN
LABEL1:
    MOV SI, CX
    ADD SI, OFFSET INPUT
    DEC SI
    CMP BYTE PTR [SI], 64 ; OR HEX ?
    JLE NT
    MOV AX, [SI]
    SUB AX, 55        ; 37h
    MOV [SI], AX
    JMP ND
  NT:
    MOV AX, [SI]
    SUB AX, 48        ; 30h
    MOV [SI], AX
  ND:  
    LOOP LABEL1
                      
MOV BX, 0
MOV SI, OFFSET INPUT  
MOV CX, LEN
ADD SI, CX
DEC SI                ; SI AT LAST IDX OF INPUT
MOV AL, 1

LABEL2:
    PUSH AX
    MUL BYTE PTR [SI]
    ADD BX, AX
    POP AX
    MUL A        
    DEC SI
    LOOP LABEL2
; NOW BX HOLDS 10 BASE VALUE.. OR BL.. :)

MOV AH, 0
MOV AL, BL             ; AH IS HOPEFULLY 00h -_- IT'S NOT.. CHANGE IT
MOV CX, 0
LABEL3:
    MOV AH, 0
    MOV SI, OFFSET OUTPUT
    ADD SI, CX       
    DIV B
    MOV BYTE PTR [SI], AH
    INC CX
    CMP AL, 0
    JNZ LABEL3
MOV BYTE PTR [SI], AH

; NOW WE MUST OPTIMIZE THE CHARS FOR >10 DIGITS

MOV BX, 0
LABEL4:
    MOV SI, OFFSET OUTPUT
    ADD SI, BX
    CMP [SI], 9
    JLE ELSE
    
    MOV AX, [SI]
    ADD AX, 55
    MOV [SI], AX
    JMP CONT
  ELSE:
    MOV AX, [SI]
    ADD AX, 48
    MOV [SI], AX
  CONT:
    INC BX
    CMP BX, CX
    JL LABEL4

CALL PTHIS
DB 10, 13, "the answer is:", 10, 0
MOV AH, 0Eh
PRINT:
    MOV SI, OFFSET OUTPUT
    ADD SI, CX
    DEC SI ; ??
    MOV AL, BYTE PTR [SI]
    INT 10h
    LOOP PRINT

; BACK TO FUTURE
MOV AX, 4C00h
INT 21h
RET

STRLEN PROC              ; SHOULD BE EDITED
    LEA SI, INPUT
    MOV DI, 0
  LABEL:
    CMP [SI], 0          
    JE RETURN
    INC DI
    INC SI
    JMP LABEL
  RETURN:
    MOV LEN, DI        
    RET
STRLEN ENDP

A       DB ?                ; NUMBER'S BASE
B       DB ?                ; NEW BASE
LEN     DW ?
INPUT   DB 10 DUP(?)
OUTPUT  DB 10 DUP(?)

DEFINE_SCAN_NUM
DEFINE_PTHIS

END
