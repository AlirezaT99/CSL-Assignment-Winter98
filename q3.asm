; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "insert a number with space : $"  
    array dw 1000 dup(?)
    n dw 0
    flag db 0
    
ends

stack segment
    dw   128  dup(0)
ends
extra segment  
  
    
ends

code segment
    assume cs:code, ds:data, ss:stack, es:extra
    intialize proc near
        push ax
        push bx
        push cx
        push dx
        
        mov cx, n
        l10:
            mov ax, cx   ;move cx to ax
            mov bl, 2
            mul bl       ; double ax to have addres of array house
            mov bx, ax        ; move it to bx for indexing
            mov word ptr array+[bx-2], cx     ;the last house must be n and lesser when we go back
            loop l10    
         
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    
    calcute proc near
        push ax
        push bx
        push cx
        push dx
        
        mov dx, n  ;use it to have count of array elemnt that are not omitted
        l1:
            mov cx, n  ;use for loop on array
            sub bx, bx  ;indexing array          
            l2:
                mov ax, word ptr array+[bx]
                cmp ax, 0    ;if house is 0 it is removed
                je jump
                mov al ,byte ptr flag
                cmp al, 0     ;if flag is 1 houst should be removed
                je continue1
                jne continue2
                continue1:        ;do nothing 
                    mov byte ptr flag, 1
                    jmp jump
        
                continue2:      ;remove element
                    mov word ptr array+[bx], 0
                    dec dx     ;dec dx when house is removed
                    mov byte ptr flag, 0
                    jmp jump
         
                jump:  ;loop on array
                    cmp dx, 1    ;if one house remaind we must quit
                    je fin4
                    add bx, 2    ;add to index
                    loop l2
         
           jmp l1
    fin4:
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp   
    
    
    
    print proc near
        push ax
        push bx
        push cx
        push dx
        
        sub cx, cx
        mov bp, sp
        mov ax, word ptr [bp+10]  ;load int
        lo:  
            sub dx, dx   ;use dx for reminder of divide
            div word ptr 10
            add dx, '0'     ;make int to char
            push dx         ;push it to stack
            inc cx          ;use it for counter to print  
            cmp ax, 0   ;if it became 0 it is over
            je fin
            jmp lo
        fin:
            pop ax          ;load first decimal
            mov dl, al
            mov ah, 2
            int 21h         ;print it
            loop fin      
         
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    
    
    loadn proc near
        push ax
        push bx                     
        
        push cx
        push dx
        
        sub bx, bx  ;for our number
        l:
        mov dx, 10  ;use it for make it to an int
        mov ah, 1
        int 21h     ;load char
        cmp al, ' ' ;check
        je finish
        cmp al, 13  ;check
        je finish
        sub al, '0' ;change char to int
        and ax, 00ffh ;remove ah that is not our number
        mov cx, ax  ;mov ax to add to bx later
        mov ax, bx
        mul dx      ;mul bx , 10 in ax
        mov bx, ax  ;set bx
        add bx, cx  ;add loaded decimal
        jmp l 
        finish:
        mov n, bx
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
    mov ax, extra
    mov es, ax    ;load segments

    lea dx, pkey
    mov ah, 9
    int 21h      ;print string
    
    
    call loadn
    
    call intialize
    
    call calcute
    
    mov dl, 10
    mov ah, 2
    int 21h
    
    mov dl, 13
    mov ah, 2
    int 21h    ;next line
    
    mov cx, n
    sub bx,bx
    ls1:
        mov ax, word ptr array+[bx]     ;load house
        cmp ax, 0                       ;check if it is not removed
        jne fin1
        add bx, 2                       ;inc bx for indexing
        loop ls1
        fin1:                  
            push ax
            call print                  ;print result 
            
            
            
    mov ah, 1
    int 21h ;wait for a key

    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
