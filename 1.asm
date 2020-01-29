; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$"
    n dw (0)
    matris dw 10000 dup(?)
ends

stack segment
    dw   128  dup(0)
ends 


extraCode segment 
addNMulR proc far
    push ax
    push bx
    push cx
    push dx
    
    mov ds, [sp+16]
    mov bx, [sp+14]
    
    
    
    
    pop dx
    pop cx
    pop bx
    pop ax
    
    
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax 
    mov ax, extraCode
    mov es, ax

    ; add your code here
            
    ;lea dx, pkey
    ;mov ah, 9
    ;int 21h        ; output string at ds:dx
    
    ; wait for any key....
    sub bx, bx    
    mov ah, 1
    int 21h
    sub al, '0'
    and ax, 0fh
    add bx, ax
    
    mov ah, 1
    int 21h
    sub al, '0'
    and ax, 0fh
    mov dx, 10
    mul dx
    add bx, ax
    mov n, bx  ;load n  
    
    push segment matris
    push offset matris
        
    mov ah, 1
    int 21h
    sub al, '0'
    and ax, 0fh
    push ax    ;s
    
    mov ah, 1
    int 21h
    sub al, '0'
    and ax, 0fh
    push ax    ;r
    
    mov ah, 1
    int 21h
    sub al, '0'
    and ax, 0fh
    push ax      ;c
    
    
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
