; multi-segment executable file template.

data segment
    ; add your data here!
    treasure db "reached treasure!$"
    obstacle db "can not move, obstacle ahead$"
    getTreasure db "Tresure position : $"
    getObstacleCount db "Obstacle count : $"
    obstaclePosition db "Obstacle positoin : $"
    moves db "get moves : $"
    xTreasure dw ?
    yTreasure dw ?
    xObstacle dw 1000 dup(?)
    yObstacle dw 1000 dup(?)
    countOfObstacle dw ?
    num dw ?
    x dw 0
    y dw 0
    flag db 1
ends

stack segment
    dw   400  dup(0)
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
            inc cx
            cmp ax, 0   ;if it became 0 it is over
            je fin          ;use it for counter to print
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
        mov word ptr num, bx    ;save input
        
        
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    loadObstacle proc near 
        push ax
        push bx                     
        push cx
        push dx
        
        mov dx, offset getObstacleCount
        mov ah, 9
        int 21h
        call load
        mov cx, num
        mov countOfObstacle, cx  ; get count of obstacle
        
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h  ;new line
        
        l3:
        mov dx, offset obstaclePosition
        mov ah, 9
        int 21h
        mov ax, cx
        dec ax
        mov bx, 2
        mul bx
        mov bx, ax ;prepare index
        
        call load
        mov ax, num
        mov xObstacle+[bx], ax
        call load
        mov ax, num
        mov yObstacle+[bx], ax  ;load obstacle position
        
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h  ;new line
        
        loop l3
        
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp 
    
    
    moveToWin proc near
        push ax
        push bx                     
        push cx
        push dx
        
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h  ;new line
        
        call load
        
        mov dl, 10
        mov ah, 2
        int 21h
        mov dl, 13
        mov ah, 2
        int 21h  ;new line
        
        mov ax, num
        add ax, '0'
        
        cmp ax, 'u'
        jne cont1
        call up
        jmp fin4
        
        cont1:
        cmp ax, 'd'
        jne cont2
        call down
        jmp fin4
        
        cont2:
        cmp ax, 'r'
        jne cont3
        call right
        jmp fin4
        
        cont3:
        cmp ax, 'l'
        jne fin4
        call left
         
        fin4:
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    up proc near
        push ax
        push bx
        push cx
        push dx
        
        mov ax, x
        mov bx, y
        inc bx     ;mov it 
        
        push ax
        push bx   ;input function
        
        call check
        cmp byte ptr flag, 1
        jne fin51 ;check it is true mov or not if it is not true do not save it
        
        mov x, ax
        mov y, bx   ;save position 
        
        push ax
        call print
        mov dl, ' '
        mov ah, 2
        int 21h
        push bx
        call print ;print position
        
        jmp fin5
        
        fin51:
        mov dx, offset obstacle
        mov ah, 9
        int 21h ;error 
        
        fin5:
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    down proc near
        push ax
        push bx
        push cx
        push dx
        
        mov ax, x
        mov bx, y
        dec bx     ;mov it
        
        push ax
        push bx   ;input function
        
        call check
        cmp byte ptr flag, 1
        jne fin61 ;check it is true mov or not if it is not true do not save it
        
        mov x, ax
        mov y, bx  ;save position
        
        push ax
        call print
        mov dl, ' '
        mov ah, 2
        int 21h
        push bx
        call print ;print position
        
        jmp fin6
        
        fin61:
        mov dx, offset obstacle
        mov ah, 9
        int 21h ;error 
        
        fin6:
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    
    right proc near
        push ax
        push bx
        push cx
        push dx
        
        mov ax, x
        mov bx, y
        inc ax     ;mov it 
        
        push ax
        push bx   ;input function
        
        call check
        cmp byte ptr flag, 1
        jne fin71 ;check it is true mov or not if it is not true do not save it
        
        mov x, ax
        mov y, bx  ;save
        
        push ax
        call print
        mov dl, ' '
        mov ah, 2
        int 21h
        push bx
        call print ;print position
        
        jmp fin7
        
        
        fin71:
        mov dx, offset obstacle
        mov ah, 9
        int 21h ;error 
                       
                       
        fin7:
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    
    left proc near
        push ax
        push bx
        push cx
        push dx
        
        mov ax, x
        mov bx, y
        dec ax     ;mov it 
        
        push ax
        push bx   ;input function
        
        call check
        cmp byte ptr flag, 1
        jne fin81 ;check it is true mov or not if it is not true do not save it
        
        mov x, ax
        mov y, bx ;save position
        
        push ax
        call print
        mov dl, ' '
        mov ah, 2
        int 21h
        push bx
        call print ;print position
        
        jmp fin8
        
        fin81:
        mov dx, offset obstacle
        mov ah, 9
        int 21h ;error 
                
        
        fin8:

        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    check proc near
        push ax
        push bx
        push cx
        push dx
        
        mov byte ptr flag, 1 ; reset flag
        
        mov bp, sp
        mov dx, [bp+12] ;x
        mov bx, [bp+10] ;y   ;load inputs
        
        
        mov cx, countOfObstacle
        l9:
        mov ax, cx
        dec ax
        add ax, ax
        mov si, ax
        cmp xObstacle+[si], dx
        jne loop1
        cmp yObstacle+[si], bx
        jne loop1      ;check with obstacle
        mov byte ptr flag, 0   ;it is obstacle
        jmp fin9
        
        loop1:
        loop l9
        
        fin9:
        pop dx
        pop cx
        pop bx
        pop ax
        ret 4
    endp
    
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    mov ax, stack
    mov ss, ax
            
    lea dx, getTreasure
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    call load
    mov ax, num
    mov xTreasure, ax
    call load
    mov ax, num
    mov yTreasure, ax ;load treasure position
    
    mov dl, 10
    mov ah, 2
    int 21h
    mov dl, 13
    mov ah, 2
    int 21h     ;new line
    
    call loadObstacle
    
    
    mov dx, offset moves
    mov ah, 9
    int 21h
    
    mainloop:
    
    call moveToWin
    mov ax, x
    mov bx, y
    cmp ax, xTreasure
    jne mainloop
    cmp bx, yTreasure
    jne mainloop
    
    mov dl, 13
    mov ah, 2
    int 21h
    mov dl, 10
    mov ah, 2
    int 21h
    
    
    mov dx, offset treasure
    mov ah, 9
    int 21h
    
    
    mov ah, 1
    int 21h ;wait for a key
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
