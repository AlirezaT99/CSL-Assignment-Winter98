; multi-segment executable file template.

data segment
    ; add your data here!
    codekey db "code turn: $"  
    userkey db "your turn: $"
    hopkey db "hop$"
    loosekey db "You lost!!:($"
    step dw 3     ;define steps
    turn dw 4     ;define start point and hold it
    num dw ?      ;hold user number
    flagprim db 1 ;result of checking number is prime or not
    flagcont db 1 ;hold the code must continue or not
    flagwin db 1  ;hold user lose or not ,0 mean user lost
    hopflag db 0  ;1 if user type hop
ends

stack segment
    dw   128  dup(0)
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
        ret 2
    endp
    
    
    
    
    load proc near
        push ax
        push bx                     
        push cx
        push dx
        
        mov byte ptr hopflag, 0
        sub bx, bx  ;for our number
        l:
        mov dx, 10  ;use it for make it to an int
        mov ah, 1
        int 21h     ;load char
        cmp al, ' ' ;check
        je finish
        cmp al, 13  ;check
        je finish
        cmp al, 'h'
        je gethop
        sub al, '0' ;change char to int
        and ax, 00ffh ;remove ah that is not our number
        mov cx, ax  ;mov ax to add to bx later
        mov ax, bx
        mul dx      ;mul bx , 10 in ax
        mov bx, ax  ;set bx
        add bx, cx  ;add loaded decimal
        jmp l
        
         
        gethop:
        mov ah, 1
        int 21h
        mov ah, 1
        int 21h 
        mov ah, 1
        int 21h    ; catch hop
        mov byte ptr hopflag, 1 ;change hopflag because of hop input
          
          
        finish:
        mov word ptr num, bx    ;save input
        
        
        
        
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h  ;new line
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    
    checkprime proc near     ;check prime start from input-1
        push ax
        push bx                     
        push cx
        push dx
        
        mov bp, sp
        mov ax, word ptr [bp+10] ;load number
        mov bx, ax  ;use bx to have input number because ax change in every divide
        mov cx, ax  
        dec cx      ;use cx to make number for check
        mov byte ptr flagprim, 1  ;set default of flag
        
        cmp ax, 2
        jne l2
        je fin2     ;check num 2
         
        l2:
            sub dx,dx
            div cx
            cmp dx, 0  ;if dx is 0 it means input is a multiple of another number so it is not prime
            jne cont
            mov byte ptr flagprim, 0
            je fin2 
            cont:
            cmp cx, 2  ;check finish condition
            je fin2
            dec cx    ;make ready cx for new step
            mov ax, bx  ;reload ax
            jne l2
        
       
       
       
        fin2:
        pop dx
        pop cx
        pop bx
        pop ax
        ret 2
    endp
     
     
     
    move proc near
        push ax
        push bx                     
        push cx
        push dx
        
        mov ax, word ptr turn
        push ax                   ;load turn and push it to stack as input
        call checkprime
        cmp byte ptr flagprim, 1  ;check turn 
        je hop      ;if it is prime say hop
        jne el       ;else print turn
        
        hop:
            lea dx, hopkey
            mov ah, 9
            int 21h
            mov dl, 13
            mov ah, 2
            int 21h
            mov dl, 10
            mov ah, 2
            int 21h
            jmp fin4     ;say hop and new line
        el:
            push ax
            call print
            jmp fin4      ;print turn
        
        fin4:
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    
    user proc near
        push ax
        push bx                     
        push cx
        push dx
        
        call load
        call check    ;load input and check it
        
        cmp byte ptr flagwin, 1    ; if flagwin is 1 all thing is write
        je fin3
        mov byte ptr flagcont, 0   ;else user lose and must make flagcont to 0 to not continue code
        lea dx, loosekey
        mov ah, 9
        int 21h
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h     ; print you lose
        
        
        
        fin3:
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
        
        
        mov ax, word ptr turn
        push ax
        call checkprime
        cmp byte ptr flagprim, 1  ;if turn is prime user must type hop
        je chop
        cmp byte ptr hopflag, 0   ;else huser must not say hop
        je checknum                ; and must say right number
        
        mov byte ptr flagwin, 0    ;else if user type hop he lose
        jmp fin10 
        
        
        chop:
        cmp byte ptr hopflag, 1    ;check user say hop
        je fin10
        mov byte ptr flagwin, 0    ;if user dont say hop he lose
        jmp fin10
        
        checknum:
        mov ax, num      ;load user input
        cmp ax, turn     ;compare it with turn
        je fin10         ;if they are equal all is well
        mov byte ptr flagwin, 0   ;else he lose
        
          
        
        fin10:  
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
    mov ss,ax

    ; add your code here
    l1:        
        lea dx, codekey
        mov ah, 9
        int 21h        ;show that is code turn
        
        call move
        
        mov ax, turn
        add ax, step
        mov turn, ax   ;make turn go a step further
        
        lea dx, userkey
        mov ah, 9
        int 21h    ;show that is user turn
        
        call user
        
        mov ax, turn
        add ax, step
        mov turn, ax   ;make turn go a step further
        
        cmp byte ptr flagcont, 1 ;check that code must continue or not
        je l1    
        
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
