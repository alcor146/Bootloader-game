.model tiny
_text segment use16

org 7C00h

start:
    jmp main

;ball that moves on the X axis only     
ball_x db 0       
ball_y db 15        
ball_dx db 1   

; the player that needs to reach the gate
paddle_x db 75   
paddle_y db 20  
paddle_dx db 0          
paddle_dy db 0 

; after 3 cycles (when it reqaches the other end of the screens and resets) the game will end
timer_x db 1
; I keep count of the number of cycles
time_limit db 0 


main:
    
    ; initialization
    mov ax, cs
    mov ds, ax

    ; hide he cursor
    mov ch, 32
    mov ah, 1
    int 10h         ;  INT 10h / AH = 01h - set text-mode cursor shape.

    ;clear the screen
    mov cx, 25
cls:
    mov ah, 0Eh
    mov al, 10
    int 10h         
    loop cls
    
   
game:

   
    call gate_draw
    
    call ball_draw
    sub ball_y, 10
    call ball_draw
    
    call paddle_draw
    add paddle_y, 1
    call paddle_draw
    sub paddle_y, 1

    call wall_draw
    add timer_x, 1
    
  
    call check_collision
    add ball_y, 10
    call check_collision
    
    call delay
    
  
    call ball_erase
    sub ball_y, 10
    call ball_erase
    add ball_y, 10

    
    call paddle_erase
    add paddle_y, 1
    call paddle_erase
    sub paddle_y, 1
    
    call wall_erase
    
    .if (timer_x == 83)
        mov timer_x, 0
        inc time_limit
    .endif
    
    .if(time_limit == 3)
        jmp Ending
    .endIf

    call ball_move
    call paddle_move
    
    
    
    .if (paddle_x == 0) && (paddle_y == 0)
        jmp Ending
    .endif


    jmp game


check_collision proc
    mov al, paddle_x
    mov bl, paddle_y
    .if (al == ball_x) && (bl == ball_y)   
        jmp Ending
    .endif

    add bl, 1
    .if (al == ball_x) && (bl == ball_y)
        jmp Ending
    .endif
    sub bl, 1
    
check_collision endp


; number of fps
delay proc
    mov ah, 086h
    mov cx, 0
    mov dx, 25000
    int 15h         ;  INT 15h / AH = 86h - BIOS wait function. 
    ret
delay endp

;set the new position of the ball
ball_setpos proc
    mov dl, ball_x
    mov dh, ball_y
    mov bh, 0
    mov ah, 2
    int 10h        
    ret
ball_setpos endp

;draw the ball at the new position
ball_draw proc
    call ball_setpos
    mov ah, 0Ah
    mov al, 'O'
    mov cx, 1
    int 10h        
    ret
ball_draw endp

;clear the screen at the previous position of the ball
ball_erase proc
    call ball_setpos
    mov ah, 0Ah
    mov al, ' '
    mov cx, 1
    int 10h        
    ret
ball_erase endp

;calculating the new  position of the ball
ball_move proc
    mov al, ball_x
    mov bl, ball_dx
    add al, bl
    mov ball_x, al

    .if (al == 79) || (al == 0)
        neg ball_dx
    .endif
    
    ret
ball_move endp


paddle_setpos proc
    mov dl, paddle_x
    mov dh, paddle_y
    mov bh, 0
    mov ah, 2
    int 10h
    ret
paddle_setpos endp


paddle_draw proc
    call paddle_setpos
    mov ah, 0Ah
    mov al, '*'
    mov cx, 2       
    int 10h         
    ret
paddle_draw endp


paddle_erase proc
    call paddle_setpos
    mov ah, 0Ah
    mov al, ' '
    mov cx, 2
    int 10h        
    ret
paddle_erase endp


paddle_move proc
    mov ah, 1
    int 16h         ;  INT 16h / AH = 01h - check for keystroke in the keyboard buffer.
    je no_key       ;  ZF = 1 if keystroke is not available.
    
    mov ah, 0       ;  INT 16h / AH = 00h - get keystroke from keyboard (no echo).
    int 16h         ;  (if a keystroke is present, it is removed from the keyboard buffer). 


    .if (al == 'a')
        mov paddle_dx, -1
        mov paddle_dy, 0
    .endif

    .if (al == 'd')
        mov paddle_dx, 1
        mov paddle_dy, 0
    .endif
    
    .if al == 'w'
        mov paddle_dx, 0
        mov paddle_dy, -1
    .endif
    
    .if (al == 's') 
        mov paddle_dx, 0
        mov paddle_dy, 1
    .endif
    
    mov al, paddle_x
    mov bl, paddle_dx
    add al, bl
    
    .if (al <= 80-2) &&  (al >= 0)
        mov paddle_x, al
    .endif
    
    mov al, paddle_y
    mov bl, paddle_dy
    add al, bl
    
    .if (al <= 23)
        mov paddle_y, al 
    .endif
no_key:            
    
    ret
paddle_move endp


;the gate is the goal that the playes has to reach to win
gate_setpos proc
    mov dl, 0
    mov dh, 0
    mov bh, 0
    mov ah, 2
    int 10h
    ret
gate_setpos endp


gate_draw proc
    call gate_setpos
    mov ah, 0Ah
    mov al, 'G'
    mov cx, 1      
    int 10h      
    ret
gate_draw endp

;the wall is the timer itself
wall_setpos proc
    mov dl, 0
    mov dh, 24
    mov bh, 0
    mov ah, 2
    int 10h
    ret
wall_setpos endp 


wall_draw proc  
    call wall_setpos    
    mov ah, 0Ah 
    mov al, '=' 
    mov bl, timer_x
    mov bh, 0
    mov cx, bx
    int 10h             
    ret 
wall_draw endp  


wall_erase proc 
    call wall_setpos    
    mov ah, 0Ah 
    mov al, ' ' 
    mov bl, timer_x
    mov bh, 0
    mov cx, bx
    int 10h         
    ret 
wall_erase endp 


Ending:
;   bootloader signature
db 510-($-start) dup(0)
dw 0AA55h

_text ends
end
