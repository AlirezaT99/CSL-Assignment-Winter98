; multi-segment executable file template




data segment
    ; add your data here!
    pkey db "choose your option from 1 to 6 with write parameters : $"
    filled db 1000 dup(0)
    nums dw 1000 dup(?)
    nexts dw 1000 dup(-1)
    pres dw 1000 dup(-1)
    first dw -1
    last dw -1
    num dw ?
    
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
        mov bx, ax
        mov ax, word ptr filled+[bx]
        cmp ax, 0
        je finloop1
        loop l2

        
        
        finloop1: 
        call load
        mov ax, num
        mov word ptr filled+[bx], 1
        mov nums+[bx], ax
        mov ax, first
        cmp ax, -1
        je jf
        
        mov nexts+[bx] , ax
        mov si, ax
        mov pres+[si], bx
        jmp jf
        
        jf:
        mov first, bx
        
        
        mov ax, last
        cmp ax, -1
        jne fin2
        mov last, bx
        
        
        
        fin2:
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h
        
        
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
        mov bx, ax
        mov ax, word ptr filled+[bx]
        cmp ax, 0
        je finloop2
        loop l4

        
        
        finloop2: 
        call load
        mov ax, num
        mov word ptr filled+[bx], 1
        mov nums+[bx], ax
        mov ax, last
        cmp ax, -1
        je jf2
        
        mov pres+[bx] , ax
        mov si, ax
        mov nexts+[si], bx
        jmp jf2
        
        jf2:
        mov last, bx
        
        
        mov ax, first
        cmp ax, -1
        jne fin4
        mov first, bx
        
        
        
        fin4:
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h
        
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
        int 21h
        
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
        jmp l3
        
        fin3:
        mov dl, 10
        mov ah, 2
        int 21h
        mov dl, 13
        mov ah, 2
        int 21h
        
        
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
            cmp ax, 0   ;if it became 0 it is over
            je fin
            sub dx, dx   ;use dx for reminder of divide
            div bx
            add dx, '0'     ;make int to char
            push dx         ;push it to stack
            inc cx          ;use it for counter to print
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
        and ax, 0fh ;remove ah that is not our number
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
