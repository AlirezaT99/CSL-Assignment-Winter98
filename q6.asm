; multi-segment executable file template.

data segment
    ; add your data here!
    countOfDot db "Count of dots : $"
    dot db "Dot position and flag (x y flag) : $"
    line db "Line is : $"
    count dw 0
    xDots dw 1000 dup(?)
    yDots dw 1000 dup(?)
    flagDots dw 1000 dup(?)
    min dw 1000
    x dw ?
    y dw ?
    num dw ?
    tempX dw ?
    tempY dw ?
ends

stack segment
    dw   500  dup(0)
ends

code segment
     
     
    print proc near
        push ax
        push bx
        push cx
        push dx
        
        sub cx, cx
        mov bp, sp
        mov bx, 10
        mov ax, word ptr [bp+10]  ;load int
        lo:  
            sub dx, dx   ;use dx for reminder of divide
            div bx
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
        ret 2
    endp
    
    
    
    load proc near
        push ax
        push bx                     
        push cx
        push dx
        

        sub bx, bx  ;for our number
        l1:
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
        jmp l1
              
          
        finish:
        mov word ptr num, bx    ;save input
        
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    loadDots proc near
        push ax
        push bx
        push cx
        push dx
        
        mov cx, count ;load count to cx as loop counter
        l3:
        mov ax, cx
        dec ax
        mov bx, 2
        mul bx
        mov ax, bx ; prepare index for address
        
        push bx
        call loadDot  ; dot
        loop l3
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    loadDot proc near
        push ax
        push bx
        push cx
        push dx
        
        mov bp, sp
        mov bx, [bp+10]
        
        call load
        mov ax, num
        mov xDot, ax  ; x
        
        call load
        mov ax, num
        mov yDot, ax  ; y
        
        call load
        mov ax, num
        mov flagDot, ax  ; flag
        
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret 2
    endp
    
    
    checkX proc near
        push ax
        push bx
        push cx
        push dx
        
        l6:
        
        sub dx, dx ; use to count inversion
        mov cx, count ; load count to use it as loop counter
        
        l5:
        mov ax, cx
        dec ax
        mov bx, 2
        mul bx
        mov bx, ax ; prepare index
        
        mov ax, xDots+[bx]
        cmp ax, word ptr tempX   ;compare dot with line
        jg if1                   ;if its above it
        cmp word ptr flag+[bx], 0  ;if it is below it must have flag 0
        je contloop
        inc dx             ;it does not have flag 0
        jmp contloop
        if1:
        cmp word ptr flag+[bx], 1 ;if it is above the line it must have flag 1
        je contloop
        inc dx      ;it does not have flag 1
        contloop:
        loop l5
        
        mov ax, min
        cmp ax, dx     ;load min inversion to compare
        jnl gol6       ;if it is higher it is not proper
        mov min, dx    ;it is less than before so save it
        mov ax, tempX
        mov x, ax
        mov word ptr y, 0
        gol6:
        mov ax, tempX
        cmp ax, 100          ;go until x is 100
        jg fin5
        inc ax
        mov tempX, ax       ;go to next line
        jmp l6:
         
        
        
        
        fin5:
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    checkY proc near
        push ax
        push bx
        push cx
        push dx
        
        l8:
        
        sub dx, dx ; use to count inversion
        mov cx, count ; load count to use it as loop counter
        
        l7:
        mov ax, cx
        dec ax
        mov bx, 2
        mul bx
        mov bx, ax ; prepare index
        
        mov ax, yDots+[bx]
        cmp ax, word ptr tempY   ;compare dot with line
        jg if2                   ;if its above it
        cmp word ptr flag+[bx], 0  ;if it is below it must have flag 0
        je contloop2
        inc dx             ;it does not have flag 0
        jmp contloop2
        if2:
        cmp word ptr flag+[bx], 1 ;if it is above the line it must have flag 1
        je contloop2
        inc dx      ;it does not have flag 1
        contloop2:
        loop l7
        
        mov ax, min
        cmp ax, dx     ;load min inversion to compare
        jnl gol8       ;if it is higher it is not proper
        mov min, dx    ;it is less than before so save it
        mov ax, tempY
        mov y, ax
        mov word ptr x, 0
        gol8:
        mov ax, tempY
        cmp ax, 100          ;go until y is 100
        jg fin7
        inc ax
        mov tempY, ax       ;go to next line
        jmp l8:
         
        
        
        
        fin7:
        
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    
    checkXY proc near
        push ax
        push bx
        push cx
        push dx
        
        
        
        
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
    mov es, ax
    mov ax, stack
    mov ss, ax

    ; add your code here
            
    lea dx, countOfDot
    mov ah, 9
    int 21h        ; string for get count of dots
    
    call load
    mov ax, num
    mov count, ax
    
    call loadDots
    
    call checkX
    
    call checkY
    
    call checkXY
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
