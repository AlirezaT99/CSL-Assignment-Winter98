include 'emu8086.inc'  

; SCAN INPUT
LEA BP, string
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

CALL PTHIS
DB 10, 13, '', 0    ; BLANK LINE

   
CALL STRLEN         ; DI HOLDS LENGTH OF INPUT NOW
MOV length, DI
DEC DI                                          

MOV BX, 1           ; = result_length

MOV CX, DI
OUTER: 
    MOV DI, CX         ; = i
    MOV cx_holder, CX  ; PUSH CX
    ;DEC CX             ; = j
    INNER:
      PUSH DI
      PUSH CX
      CALL ISMIRROR
      MOV DL, flag
      CMP DL, 1
      JE ENDINNER
      MOV DX, DI
      SUB DX, CX
      INC DX           ; DX = I - J + 1
      CMP DX, BX
      JLE ENDINNER
      MOV BX, DX            ; UPDATE RESULT
      MOV result_idx, CX    ; = result_idx
      ENDINNER:
        LOOP INNER 
    MOV CX, cx_holder  ; POP CX
LOOP OUTER 
   
CALL PTHIS
DB 'The largest mirror substring is: ', 0
MOV SI, OFFSET string
MOV AH, 0Eh
MOV BP, result_idx
MOV CX, BX

LABEL3:
    MOV AL, byte ptr [SI + BP]
    INT 10h       
    INC BP
    LOOP LABEL3

MOV AX, 4C00h
INT 21h

ISMIRROR PROC
    MOV BP, SP
    ADD BP, 4
    MOV SI, [BP]        ; = t   == I == DI
    MOV BP, [BP - 2]    ; = k   == J == CX    
       
    ADD BP, OFFSET string
    ADD SI, OFFSET string
 LABEL1:
    PUSH AX   
    MOV AX, [BP]
    CMP AL, byte ptr [SI]
    POP AX
    JNE FAIL
    INC BP
    DEC SI
    CMP BP, SI
    JLE LABEL1
    MOV byte ptr flag, 0
    JMP RET1
 FAIL:
    MOV byte ptr flag, 1    ; 1 IF NOT MIRROR
 RET1:      
    RET
ISMIRROR ENDP

STRLEN PROC
    LEA SI, string
    MOV DI, 0
 LABEL2:
    CMP [SI], 0
    JE RETURN
    INC DI
    INC SI
    JMP LABEL2
 RETURN:        
    RET
STRLEN ENDP

string      DB 100 dup(?)
length      DW ?                      
result_idx  DW 1
cx_holder   DW ?                      
flag        DB 0                      

DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS
DEFINE_PRINT_STRING
DEFINE_PTHIS

END
