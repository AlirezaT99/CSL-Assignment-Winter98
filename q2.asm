INCLUDE 'emu8086.inc'

; SCAN N
MOV AH, 01h
INT 21h
SUB AL, '0'
MOV BYTE PTR N, AL

INT 21h
CMP AL, 13            ; CHECKS IF N > 9
JE RSM
SUB AL, '0'
MOV AH, 0
MOV BL, 10
MOV CL, AL
MOV AL, BYTE PTR N
MUL BL
ADD AL, CL
MOV BYTE PTR N, AL

MOV BL, 0
MOV CL, 0

RSM:

CALL PTHIS
DB 10, 13, '', 0    ; BLANK LINE


; SCAN INPUT
LEA BP, INPUT
MOV AH, 01h

SCN:
INT 21h
CMP AL, 13
JE NXT
MOV [BP], AL
INC BP
JMP SCN

NXT:

CALL PTHIS
DB 10, 13, '', 0    ; BLANK LINE

; SCAN CHAR (C/R)
MOV AH, 01h
INT 21h

CALL PTHIS
DB 10, 13, '', 0    ; BLANK LINE

CMP AL, 'c'
JNE RPL
CNT:

; SCAN A
MOV AH, 01h
INT 21h
SUB AL, '0'
MOV BYTE PTR A, AL

CALL PTHIS
DB 10, 13, '', 0    ; BLANK LINE
      
; SCAN STR_A TO LOOK FOR
LEA BP, STR_A
MOV AH, 01h

SCN2:
INT 21h
CMP AL, 13
JE NXT2
MOV [BP], AL
INC BP
JMP SCN2

NXT2:

CALL PTHIS
DB 10, 13, '', 0    ; BLANK LINE

MOV AX, 0       ; COUNT
MOV CL, N
SUB CL, A
MOV DX, 0       ; = I ( FOR I: 0 -> N-A )
MOV BP, 0

LABEL1:
    PUSH DX
    PUSH CX
    CALL FIND
    POP CX
    CMP FLAG, 1
    JNE NDLP
    INC AX
    NDLP:
        INC DX
        CMP DX, CX
        JLE LABEL1

CALL PTHIS
DB 10, 13, 'The answer is:', 10, 0

CALL PRINT_NUM      ; PRINTS AX      
JMP ND

RPL:
CMP AL, 'r'
JNE ND

; SCAN A
MOV AH, 01h
INT 21h
SUB AL, '0'
MOV BYTE PTR A, AL

CALL PTHIS
DB 10, 13, '', 0    ; BLANK LINE
      
; SCAN STR_A TO LOOK FOR
LEA BP, STR_A
MOV AH, 01h

SCN3:
INT 21h
CMP AL, 13
JE NXT3
MOV [BP], AL
INC BP
JMP SCN3

NXT3:

CALL PTHIS
DB 10, 13, '', 0    ; BLANK LINE

; SCAN B      
MOV AH, 01h
INT 21h
SUB AL, '0'
MOV BYTE PTR B, AL

CALL PTHIS
DB 10, 13, '', 0    ; BLANK LINE
      
; SCAN STR_B TO REPLACE STR_B
LEA BP, STR_B
MOV AH, 01h

SCN4:
INT 21h
CMP AL, 13
JE NXT4
MOV [BP], AL
INC BP
JMP SCN4

NXT4:

MOV CL, N
SUB CL, A
MOV DX, 0       ; = I ( FOR I: 0 -> N-A )

LABEL2:
    PUSH DX
    PUSH CX
    CALL FIND
    POP CX
    CMP FLAG, 1
    JNE NDLP2
    JMP RPLC
    NDLP2:
        INC DX
        CMP DX, CX
        JLE LABEL2

JMP ND          ; REACHED IF !(STR_A IN INPUT) 

RPLC:
CALL REPLACE
MOV SI, OFFSET INPUT
MOV AH, 0Eh   
MOV CL, N
ADD CL, B
SUB CL, A       ; CX = N+B-A -> INPUT'S NEW LENGTH
MOV BP, 0

CALL PTHIS
DB 10, 13, 'The answer is:', 10, 0

LABEL3:
    MOV AL, BYTE PTR [SI + BP]
    INT 10h       
    INC BP
    CMP BP, CX
    JL LABEL3

ND:
MOV AX, 4C00h
INT 21h   
RET

FIND PROC
MOV BP, SP
MOV DI, [BP + 4]    ; = i
MOV BP, 0           ; = j
ADD DI, OFFSET INPUT    ; INPUT[i]
MOV SI, OFFSET STR_A
MOV CL, A           

LP: 
    PUSH AX
    MOV AL, BYTE PTR [SI + BP]
    CMP AL, BYTE PTR [DI + BP]
    POP AX
    JNE FAIL
    
    INC BP
    CMP BP, CX
    JL  LP

MOV FLAG, 1
JMP RT

FAIL:
    MOV FLAG, 0
RT:
    RET
FIND ENDP


REPLACE PROC
MOV BP, SP
MOV BP, [BP + 2]    ; = i
MOV AX, 0
MOV AL, A
ADD BP, AX          ; = j = i+a


MOV DI, OFFSET INPUT
MOV SI, DI

MOV AL, 0
ADD AL, B
CMP AL, A
JG  OK     
MOV AH, 0FFh    ; negative amount stored correctly

OK:
SUB AL, A
ADD DI, AX      ; DI = INPUT[B - A]

MOV AH, 0

L1:             ; SHIFTS CHARACTERS AFTER REPLACEMENT INDEX ACCORDINGLY
    MOV AL, BYTE PTR [SI + BP] 
    MOV [DI + BP], AL
    
    MOV AL, N
    INC BP
    CMP BP, AX
    JLE L1

MOV BP, SP
MOV BP, [BP + 2]    ; = i
ADD BP, OFFSET INPUT
MOV DI, BP          ; = INPUT[i]
MOV BP, 0           ; = j
MOV SI, OFFSET STR_B

L2:             ; REPLACE NEW STRING
    MOV AL, BYTE PTR [SI + BP] 
    MOV [DI + BP], AL
    
    MOV AL, B
    INC BP
    CMP BP, AX    
    JL L2    

    
RET
REPLACE ENDP


N     DB ?
A     DB ?
B     DB ?
C     DB ?
STR_A DB 20 DUP(?)
STR_B DB 20 DUP(?)
INPUT DB 20 DUP(?)
FLAG  DB ?

DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS
DEFINE_SCAN_NUM
DEFINE_PTHIS

END
