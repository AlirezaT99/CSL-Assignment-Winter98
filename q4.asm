; multi-segment executable file template




data segment
    ; add your data here!
    pkey db "choose your option from 1 to 6 with write parameters : $"
    nkey db "not found :( $"
    filled db 1000 dup(0)   ;check that is full or not if 1 mean full
    nums dw 1000 dup(?)     ;hold nums
    nexts dw 1000 dup(-1)   ;hold next
    pres dw 1000 dup(-1)    ;hold previos
    first dw -1             ;holf first of link list
    last dw -1              ;hold last of link list
    num dw ?                ;hold input number
    
ends

stack segment
    dw   1000  dup(0)
ends

code segment 
    
    menu proc near
        push ax
        push bx
        push cx
        push dx
        
        call load ; get option
        mov ax, num
        cmp ax, 1
        je getstart
        cmp ax, 2
        je getfinish
        cmp ax, 3
        je insertAfter
        cmp ax, 4
        je delete
        cmp ax, 5
        je index
        cmp ax, 6
        je printArray
        
        
        getstart:
        call addAtFirst
        jmp fin1
        
        getfinish:
        call addAtEnd
        jmp fin1
        
        insertAfter:
        call insertAfterNum
        jmp fin1
        
        delete:
        call deleteNum
        jmp fin1
        
        index:
        call findIndex
        jmp fin1
        
        printArray:
        call printAll
        jmp fin1
        
        
        
        fin1:
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    addAtFirst proc near
        push ax
        push bx
        push cx
        push dx
        
        mov cx, 500
        l2:
        mov ax, cx
        dec ax
        mov bx, 2
        mul bx
        mov bx, ax   ;prepare adrres loop counter must add -1 and mul 2
        mov ax, word ptr filled+[bx]
        cmp ax, 0    ; check house is empty or not
        je finloop1  ;if it is empty it is okay
        loop l2

        
        
        finloop1: 
        call load  ;load number
        mov ax, num
        mov word ptr filled+[bx], 1 ;mark house as full
        mov nums+[bx], ax       ;set it num
        mov ax, first
        cmp ax, -1       ;check if link list is empty
        je jf
        
        mov nexts+[bx] , ax
        mov si, ax
        mov pres+[si], bx    ;set next and pre for adding bx is new input and ax is first
        jmp jf
        
        jf:    ;if list is empty we must mark this house as start
        mov first, bx
        
        
        mov ax, last
        cmp ax, -1
        jne fin2
        mov last, bx     ;if last is empty it must be set
        
        
        
        fin2:
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h        ;new line
        
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    addAtEnd proc near
        push ax
        push bx
        push cx
        push dx
        
        mov cx, 500
        l4:
        mov ax, cx
        dec ax
        mov bx, 2
        mul bx
        mov bx, ax     ;prepare adrres loop counter must add -1 and mul 2
        mov ax, word ptr filled+[bx]
        cmp ax, 0      ; check house is empty or not
        je finloop2    ;if it is empty it is okay
        loop l4        
        
        
        finloop2: 
        call load      ;load number
        mov ax, num
        mov word ptr filled+[bx], 1   ;mark house as full
        mov nums+[bx], ax     ;set it num
        mov ax, last
        cmp ax, -1      ;check if link list is empty
        je jf2
        
        mov pres+[bx] , ax
        mov si, ax
        mov nexts+[si], bx    ;set next and pre for adding bx is new input and ax is first
        jmp jf2
        
        jf2:
        mov last, bx
        
        
        mov ax, first
        cmp ax, -1
        jne fin4
        mov first, bx      ;if first is empty it must be set
        
        
        
        fin4:
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h    ;new line
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    
    
    insertAfterNum proc near
        push ax
        push bx
        push cx
        push dx
        
        
        call load      ;load number
        mov cx, 500
        l6:
        mov ax, cx
        dec ax
        mov bx, 2
        mul bx
        mov bx, ax     ;prepare adrres loop counter must add -1 and mul 2
        mov ax, word ptr filled+[bx]
        cmp ax, 0        ; check house is empty or not
        je finloop6      ;if it is empty it is okay
        loop l6
        
        
        
        finloop6:
        mov si, bx
        mov filled+[si], 1  ;mark house as full
        mov ax, num
        mov nums+[si], ax    ;set it num
                             
        call load    ;load number that must insert after
        mov bx, first
        l5:
        cmp bx, -1
        je fin51        ;it means it does not exist
        mov ax, nums+[bx]
        cmp ax, word ptr num
        je finloop5
        mov bx, nexts+[bx]  ;find it by start from first and compare it and go next until find
        jmp l5
        
        finloop5:
        mov pres+[si], bx
        mov ax, nexts+[bx]
        mov nexts+[si], ax
        mov ax, si
        mov nexts[bx], ax  ;set pre and next bx is elemt must add after and ax is the num must be added
        
        cmp last, bx
        jne finl
        mov last, si ;if the element is last ,lasst must be changed
        jmp finl
        
        fin51:
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h     ;new line
        
        lea dx, nkey
        mov ah, 9
        int 21h     ; print does not exist
        
        
        
        finl:
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h     ;new line
        
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    
    
    deleteNum proc near
        push ax
        push bx
        push cx
        push dx
        
        call load
        sub cx, cx
        mov bx, first
        l8:
        cmp bx, -1
        je fin81   ;if do not find
        inc cx
        mov ax, nums+[bx]
        cmp ax, word ptr num
        je finloop8
        mov bx, nexts+[bx]
        jmp l8         ;find number
        
        
        finloop8:
        mov word ptr filled+[bx], 0
        mov ax, pres+[bx]
        mov bx, nexts+[bx]   ; mark it as empty
        
        cmp bx, -1
        jne if2
        cmp ax, -1
        jne if11
        mov last, ax
        mov first, ax
        jmp fin8   ;it is only element
        
        if11:
        mov si, ax
        mov nexts+[si], -1
        jmp fin8   ;if it is last element
        
        if2:
        cmp ax, -1
        jne if22
        mov first, bx
        mov pres+[bx], -1
        jmp fin8    ;it is first element
        
        if22:
        mov si, ax
        mov nexts+[si], bx
        mov pres+[bx], ax
        jmp fin8          ; it is in middle
        
        fin81:
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h     ;new line
        
        lea dx, nkey
        mov ah, 9
        int 21h       ;error not exist
        
        fin8:
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h    ;new line
        
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    
    
    findIndex proc near
        push ax
        push bx
        push cx
        push dx
        
        
        call load
        sub cx, cx
        mov bx, first
        l7:
        cmp bx, -1
        je fin7
        inc cx
        mov ax, nums+[bx]
        cmp ax, word ptr num
        je finloop7
        mov bx, nexts+[bx]
        jmp l7      ;find it linke before and counting in meiddle
        
        
        fin7:
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h  ;new line
        
        lea dx, nkey
        mov ah, 9
        int 21h   ;error
        
        jmp finl2
        
        finloop7:
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h  ;new line
        
        push cx
        call print  ;print index
        
        
        finl2:
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h   ;new line
        
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    
    printAll proc near
        push ax
        push bx
        push cx
        push dx
        
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h    ;new line
        
        mov bx, first
        l3:
        cmp bx, -1
        je fin3
        mov ax, nums+[bx]
        push ax
        call print
        mov bx, nexts+[bx]
        mov dl, ' '
        mov ah, 2
        int 21h
        jmp l3        ;itrate list and print them
        
        fin3:
        mov dl, 10
        mov ah, 2
        int 21h
        mov dl, 13
        mov ah, 2
        int 21h   ;new line
        
        
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
    
    
    
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    mov ax, stack
    mov ss, ax
    
    l:
            
    lea dx, pkey
    mov ah, 9
    int 21h     ; menu write
    
    mov dl, 13
    mov ah, 2
    int 21h
    mov dl, 10
    mov ah, 2
    int 21h
    
    
    call menu
            
    
    jmp l
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
