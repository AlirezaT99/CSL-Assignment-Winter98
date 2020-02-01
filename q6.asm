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
    tempcount dw 1000 
    erortemp dw 0
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
        mov bx, ax ; prepare index for address
        
        push bx
        call loadDot  ; dot
        
        mov dl, 10
        mov ah, 2
        int 21h
        mov dl, 13
        mov ah, 2
        int 21h   ;new line
    
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
        
        lea dx, dot
        mov ah, 9
        int 21h 
        
        call load
        mov ax, num
        mov xDots+[bx], ax  ; x
        
        call load
        mov ax, num
        mov yDots+[bx], ax  ; y
        
        call load
        mov ax, num
        mov flagDots+[bx], ax  ; flag
        
        
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
        mul bl
        mov bx, ax ; prepare index
        
        mov ax, xDots+[bx]
        cmp ax, word ptr tempX   ;compare dot with line
        jg if1
        je contloop                   ;if its above it
        cmp word ptr flagDots+[bx], 0  ;if it is below it must have flag 0
        je contloop
        inc dx             ;it does not have flag 0
        jmp contloop
        if1:
        cmp word ptr flagDots+[bx], 1 ;if it is above the line it must have flag 1
        je contloop
        inc dx      ;it does not have flag 1
        contloop:
        loop l5
        
        mov ax, min
        cmp ax, dx     ;load min inversion to compare
        jl gol6       ;if it is higher it is not proper
        mov min, dx    ;it is less than before so save it
        mov ax, tempX
        mov x, ax
        mov word ptr y, 0
        gol6: 
        cmp dx, word ptr tempcount          ;go until x is 100
        jg fin5
        mov ax, tempX
        inc ax
        mov tempX, ax
        mov tempcount, dx       ;go to next line
        jmp l6
         
        
        
        
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
        
        mov ax, 1000
        mov tempcount, ax
        
        l8:
        
        sub dx, dx ; use to count inversion
        mov cx, count ; load count to use it as loop counter
        
        l7:
        mov ax, cx
        dec ax
        mov bx, 2
        mul bl
        mov bx, ax ; prepare index
        
        mov ax, yDots+[bx]
        cmp ax, word ptr tempY   ;compare dot with line
        jg if2
        je contloop                   ;if its above it
        cmp word ptr flagDots+[bx], 0  ;if it is below it must have flag 0
        je contloop2
        inc dx             ;it does not have flag 0
        jmp contloop2
        if2:
        cmp word ptr flagDots+[bx], 1 ;if it is above the line it must have flag 1
        je contloop2
        inc dx      ;it does not have flag 1
        contloop2:
        loop l7
        
        mov ax, min
        cmp ax, dx     ;load min inversion to compare
        jl gol8       ;if it is higher it is not proper
        mov min, dx    ;it is less than before so save it
        mov ax, tempY
        mov y, ax
        mov word ptr x, 0
        gol8:
        cmp dx, tempcount          ;go until y is 100
        jg fin7
        mov ax, tempY
        inc ax
        mov tempY, ax       ;go to next line 
        mov tempcount, dx
        jmp l8
         
        
        
        
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
        
        mov tempcount, 1000
        mov tempY, 1
        mov tempX, 1   ;start quantities
        
        
        l10:
        mov word ptr erortemp, 0
        mov dx, tempX     ;sheeb line
        mov cx, count     ;loop counter
        l9:
        mov ax, cx
        dec ax
        mov bx, 2
        mul bl
        mov bx, ax;index of array
        mov ax, xDots+[bx]
        mul dl           ; expected y
        cmp ax, yDots+[bx]
        jg if21  ;it is less than line
        cmp flagDots+[bx], 1   ; it is higher must have flag 1
        je contloop4
        inc erortemp
        jmp contloop4
        if21:
        cmp flagDots+[bx], 0   ; it is lower must have flag 0
        je contloop4
        inc erortemp
        jmp contloop4
        contloop4:
        loop l9
        
        mov ax, min
        cmp ax, erortemp
        jl gol10               ;compare now eror with min
        mov ax, erortemp       
        mov min, ax
        mov ax, tempX
        mov word ptr x, ax
        mov ax, tempY
        mov word ptr y, ax    ;if it is less save it
        gol10:
        mov ax, erortemp
        cmp ax, tempcount    ; check if it is more than before we must quite
        jg fin8 
        mov tempcount, ax
        inc tempx           ;next line
        jmp l10 
         
        
        
        
        
        fin8:
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
    
    mov dl, 10
    mov ah, 2
    int 21h
    mov dl, 13
    mov ah, 2
    int 21h   ;new line
    
    
    call loadDots
    
    call checkX
    
    call checkY
    
    call checkXY
    
    lea dx, line
    mov ah, 9
    int 21h
    
    cmp word ptr x, 0
    je fin10
    cmp word ptr y, 0
    je fin11
    mov dl, 'y'
    mov ah, 2
    int 21h
    mov dl, '='
    mov ah, 2
    int 21h
    mov ax, tempX
    push ax
    call print
    mov dl, 'x'
    mov ah, 2
    int 21h
    jmp fin12     ;linear
    
    fin10:
    mov dl, 'x'
    mov ah, 2
    int 21h
    mov dl, '='
    mov ah, 2
    int 21h
    mov ax, tempX
    push ax
    call print
    jmp fin12  ;x
    
    fin11:
    mov dl, 'y'
    mov ah, 2
    int 21h
    mov dl, '='
    mov ah, 2
    int 21h
    mov ax, tempY
    push ax
    call print
    jmp fin12  ;y
    
    
    fin12:
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
