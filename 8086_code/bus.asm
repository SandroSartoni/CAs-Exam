N_A equ 12     ; N1
N_B equ 12     ; N2
N_C equ 12     ; N3
N_D equ 12     ; N4
    
.model small
.stack  
.data
  A_SCHED dw 080Ah,0900h,092Dh,0A1Eh,0B1Eh,0C1Eh,0D0Fh,0E00h,0F00h,1000h,1100h,1200h
  B_SCHED dw 070Ah,080Fh,0905h,0A28h,0B00h,0E00h,0E1Eh,0F00h,0F1Eh,100Fh,102Dh,110Fh
  C_SCHED dw 081Eh,0928h,0A32h,0C00h,0D0Ah,0E14h,0F1Eh,1028h,1132h,1300h,140Ah,1514h
  D_SCHED dw 0700h,0828h,0928h,0A28h,0B28h,0C1Eh,0D1Eh,0F00h,101Eh,121Eh,141Eh,1500h
  
  a_to_b dw 16
  b_to_tp dw 29
  c_to_d dw 4
  d_to_tp dw 45 
  sms db "Insert departure time in form hh:mm ."  
  sms1 db "First available bus is at ."   
  sms2 db "With street   to   and   to    the duration time is  ."  
  sms3 db "I will arrive at swap point at ."
  sms4 db "I will leave swap point at ."           
  sms6 db "I will arrive at the office at  ."

  tmp dw 0 
  next_day_flag db 0   ; used like my flag
  tomorrow db 0
  

.code
.startup 

  
                    
  lea  di,sms       ; Retrieve the offset of sms by loading in di the effective address of that string in memory    
  call print_line   ; Call the print_line procedure
        
  call read_time    ; Procedure to get the H_LEAVE. It's stored in bx.
  call new_line     ; Print a new line
   
  mov tmp,N_B       ; Copy N_B in tmp
  push tmp          ; 1st push, save tab_b size
  
  push b_to_tp      ; 2nd push, save b_to_tp time
  lea si,B_SCHED
  push si           ; 3rd push, save tab_b starting address 
  
  mov tmp,N_A
  push tmp          ; 4th push, save tab_a size
  
  push a_to_b       ; 5th push, saving a_to_b time
  lea di,A_SCHED
  push di           ; 6th push,  save tab_a base address
  push bx           ; 7th push,  save H_LEAVE
  
  call journey_computation   ; Procedure to...
  
  pop bx                  ;riprendo il tempo di partenza in cx
  pop cx                  ;risult
  pop ax
  pop ax
  pop ax
  pop ax
  pop ax 
;**************** Print the duration time here
  push cx
  mov sms2[12],'A'
  mov sms2[17],'B'
  mov sms2[23],'B'
  mov sms2[28],'T'
  mov sms2[29],'P'
  lea  di,sms2          
  call print_line
  call print_time   
  call new_line
  pop cx  
  
;****************************
  ;push N4  it is not possible it like immediate value
  mov tmp,N_D              ; similar like precedent call of calcolo percorso
  push tmp 
  
  push d_to_tp
  lea si,D_SCHED
  push si 
  mov tmp,N_C
  push tmp  
  
  push c_to_d
  lea di,C_SCHED 
  push di
  push bx                 ;departeare time
  
  call journey_computation
  
  pop cx
  pop cx
  pop ax
  pop ax
  pop ax
  pop ax
  pop ax
 ;***************** just for print risult  
  push cx   
  mov sms2[12],'C'
  mov sms2[17],'D'
  mov sms2[23],'D'
  mov sms2[28],'T'
  mov sms2[29],'P'
  lea  di,sms2          
  call print_line  
  call print_time
  pop cx  
   
  
       
  
 .exit   



print_time proc
      
      push dx
      push bx
      push ax
      push bp
      
      mov bp,sp
      mov ah,2            ; Copy into ah<=2 in order to print something
      mov dl," "          ; Copy in dl a space in order to print it
      int 21h             ; Print two spaces
      int 21h
      
      mov ax,[bp+10]      ; Take the time to print
      mov al,0            ; Print the hour, so reset minutes
      xchg al,ah          ; And take the hour in al
      mov bx,10
      mov dx,0            ; The reminder of the division will be stored in dx
      div bx              ; While the quotient will be stored in AX
      mov ah,2            ; To print with int 21h
      mov bl,dl           ; Save the reminder in bl
      
      mov dl,al           ; Print the first number of the hour
      add dl,48           ; But before conver it in ASCII
      int 21h  
      mov dl,bl           ; Retreive the reminder and print it
      add dl,48
      int 21h
      mov dl,':'          ; To separate hour and minutes
      int 21h    
      
      mov ax,[bp+10]      ; Take the time
      mov ah,0            ; We'll print minutes now, so reset hours
      mov bx,10           ; Same as before, we'll do the division to 
      mov dx,0            ; be able to print each number that compose
      div bx              ; minutes.
      mov ah,2
      mov bl,dl
                          ; Print minutes here
      mov dl,al
      add dl,48
      int 21h  
      mov dl,bl
      add dl,48
      int 21h  
      
      push cx        
      mov cx,-1            ; Copy -1 in cx in order to check for the next_day_flag
      cmp cl,next_day_flag ; Check if next_day_flag is set
      jne end_print_time   ; If not go to end_print_time
      cmp cl,tomorrow      ; Check if we've arrived to TP (* has to be printed only for the arrival time)
      jne end_print_time   ; If not, got to end_print_time
      mov dl,'*'           ; If we're here it means we've to print a "*"
      int 21h
end_print_time:    
  
      pop cx               ; Pop everything from the stack
      
      pop bp
      pop ax
      pop bx
      pop dx
      call new_line        ; Print a new line     
      ret
  print_time endp

;print_line procedure starts here, it's "Near" meaning that 
 print_line proc Near
        
            push ax           ; Push ax in the stack so that it's not modified
            push cx           ; Push cx in the stack so that it's not modified
            mov ah,2          ; Copy in ah (upper part of ax) 2 (used to print data)
            mov cl,'.'        ; This is the end condition of the loop
            
  continue_print:   
            mov dl,[di]       ; Copy in dl a character of the string       
            cmp dl,cl         ; Compare it with the point
            je end_print_line ; If it's the point, stop printing and get out of the procedure       
            int 21h           ; int 21h is an interrupt that allows (with ah=2) to print the content of dl
            inc di            ; di=di+1 , to get the next character of the string
            jmp continue_print; Keep printing   
                
end_print_line:   
            pop cx            ; Finally, pop cx...
            pop ax            ; ... and ax.
                       
            ret               ; End the procedure
 print_line endp
   
 ; journey_computation procedure starts here     
 journey_computation proc Near
  
  push bp         ; Push base pointer on the stack
  
  mov bp,sp       ; Copy the stack pointer in the base pointer 
  push ax
  push bx
  push cx
  
  
  mov bx,[bp+4]   ; Copy in bx the departure time 
  mov di,[bp+6]   ; Load in di tab_x (x=a or c) base offset 
  mov cx,[bp+10]  ; Load in cx the dimension of the table
  
  push bx         ; Push in the stack the values copied before
  push di        
  push cx        
  
  call find
  
  pop bx       
  pop bx
  pop bx          ; Now we've the time of the next available bus
              
  lea  di,sms1    ; Load in di sms1 string
  call print_line ; Print that string                    
  push bx             
  call print_time ; Print the departure time
  pop bx           
   
  mov cx,[bp+8]   ; Load in cx "a_to_b"
  push bx
  push cx
  call add_time   ; Add a_to_b to the departure time and check for the correctness
  pop bx
  pop bx          ; Arrival time at the swap point saved in bx 
                                 
  lea  di,sms3    ; Load in di sms3 string
  call print_line ; Tell the user the arrival time at the swap point                    
  push bx             
  call print_time ; Print the swap point time
  pop bx  
                   
 ;************************* 
  
  
  mov di,[bp+12]  ; Load in di x_SCHED (x= B or D) base offset  
  mov cx,[bp+16]  ; Load in cx the size of the table
  
    
  push bx         ; Push the size of the table
  push di         ; Push the base address of the table
  push cx         ; Push the arrival time at the swap point
  
  call find       ; Search for the departure time from the swap point
  
  pop bx       
  pop bx
  pop bx          ; Now we've in bx the departure time from the swap point
  
             
  lea  di,sms4        ; Load in di sms4's base address
  call print_line     ; So that we can tell the user the departure time from the swap point                   
  push bx             
  call print_time     ; Print the departure time
  pop bx              
                
  mov cx,[bp+14]  ; Load x_to_tp (x = b or d)
  push bx         ; Push the departure time
  push cx         ; Push x_to_tp
  call add_time   ; And add the two
  pop bx
  pop bx          ; Arrival time
  
  push cx
  mov cl,-1
  mov tomorrow,cl ; Store in tomorrow '-1'
  pop cx 
              
  lea  di,sms6         
  call print_line     ; Tell the user that we arrived at TP                   
  push bx             
  call print_time     ; And tell him the arrival time
  pop bx              
   
                    
  mov cx,[bp+4]              ; Load in cx the departure time (H_LEAVE)
  push bx                    ; Push the arrival time
  push cx                    ; Push the departure time
  call duration              ; I make tiference beetwen arrived- departure time
  pop  bx
  pop  bx
  
  mov [bp+6],bx              ; Return the travel duration by stack
  
  mov al,0                   ; Reset al 
  mov next_day_flag,al       ; in order to
  mov tomorrow,al            ; modify the flags  
  
  pop cx
  pop bx
  pop ax
  
  pop  bp
                  
      ret
 journey_computation endp 
 
 ; Procedure to evaluate the duration of the whole trip
 duration proc Near
             
    push bp
    mov bp,sp
    push ax
    push bx
    push cx
    
    mov ax,[bp+6]      ; Retrieve the arrival time
    mov bx,[bp+4]      ; Retrieve the departure time
    
    cmp ax,bx          ; Check if the arrival time is greater than the departure time
    jg  check_minutes  ; If so, jump to 
    add ah,24          ; Otherwise, add 24 hours
    
check_minutes:    
    sub al,bl          ; Subtract minutes
    mov bl,0           ; Reset bl
    cmp al,bl          ; And check if originally arrival minutes were smaller than departure minutes
    jg check_hours     ; If not, go to
    add al,60          ; Else, add 60 to minutes
    dec ah             ; And decrease by one the hour

check_hours:    
    sub ah,bh          ; Subtract the hours

    
    mov [bp+6],ax      ; Save the duration of the travel on the stack
    pop cx
    pop bx
    pop ax         
    pop bp
             
          ret
 duration endp   
 
 ; Procedure to add time and check for its correctness
 add_time proc Near
    
    push bp
    mov bp,sp
    push ax
    push bx
    push cx
    
    mov ax,[bp+6]     ; Here there's the departure time  
    mov bx,[bp+4]     ; Here there's a_to_b

    add al,bl         ; Sum the minutes
    mov bl,60         ; Check if the result of the sum
    cmp al,bl         ; is greater than 60
    jl min_ok         ; If not, go to
    sub al,bl         ; Otherwise subtract 60 minutes from minutes
    inc ah            ; And add 1 to hours
    
min_ok:     
    add ah,bh         ; Add the hours 
    mov bh,24         ; Check if the sum of hours
    cmp ah,bh         ; is greater than 24
    jl no_next_day    ; If not, go to no_next_day
    sub ah,bh         ; Subtract 24 from the hours
    mov bl,-1         ; Set a flag for the next day
    mov next_day_flag , bl  ; And save it
    
no_next_day:
   
    mov [bp+6],ax     ; Return the result in the stack
    
    pop cx
    pop bx
    pop ax
    pop bp
        
    ret
add_time endp      
       
; This procedure is used to find the available bus. It checks each time in the table until it gets  
; an available time such that: time[i] > bx . If there's no available hour, then load the first time of
; the next day.
              
       
 find proc Near
    
           push bp
           mov bp,sp 
           push cx
           push ax
           push bx
           push di
           push si
           
           mov cx,[bp+4]   ; Retrieve the size of time table
           mov di,[bp+6]   ; Retrieve the base address of the time table
           mov bx,[bp+8]   ; Departure time
                     
           mov si,di       ; Take trace of the base address of the table                          
           mov ch,0        ; cl is the index for the cicle 
                                                    
  ; This cicle allows to find the time of the next available bus
                                                    
find_time: cmp ch,cl     ; Check if we've analyzed all the elements in the table
           je next_day   ; If so, it means that no available bus is present this day, so jump to next_day        
           mov ax,[di]   ; Copy the hour in ah
           cmp ax,bx     ; Check if ax >= bx
           jge  stop     ; If so it means that we've found the bus                        
           inc ch        ; Increment loop counter
           add di,2      ; Try next hour
           jmp find_time 
                          
next_day:  mov di,si     ; "Reset" di to the original position
           mov ch,-1     ; Set the flag  
           mov ax,[di]   ; Retrieve the first available time
           mov next_day_flag , ch  ; And copy it in memory
   stop:  
           mov [bp+8],ax ; Copy in the stack the time found here
           
           pop si        ; Pop everything and return
           pop di
           pop bx
           pop ax
           pop cx
           pop bp
           
           ret
 find endp



read_time proc Near
           
    push ax     ; Push ax and cx in order
    push cx     ; not to modify them
    
; Read Hour: 
; Read the first number (related to hour), if the second is ':' , then go to read minute
; otherwise, multiplicate the second by 10 and add the second number ( ex: if the hour is
; 15, then the first number is 1, then we get 10 by multiplying it by 10, and then by
; adding 5 we get 15). The same approach is used for minutes.
    
   
    mov dh,10 ; Copy in dh 10 in order to represent, for example, 21 as 2*10 + 1 
    mov ah,1  ; ah=1
    int 21h   ; When in AH we have 1 and we call int 21h, we get a character by keyword
    sub al,48 ; Subtract from the stored value 48 in order to conver it from ASCII to decimal
    mov cl,al ; Save the first character in cl
    int 21h   ; Ask for another character
    cmp al,':'; Check if it is ":" i can write 7:30 or 07:30 it procduce same risult
    je minutes; If it is equal to : then jump to minutes
    sub al,48 ; If not, it means it's another number, so copy subtract 48 as before
    mov ch,al ; And copy it in ch
    int 21h   ; Ask for ":"
    mov ax,0  ; Reset ax
    mov al,cl ; Copy the first number in al (if the hour is 12, for example, copy 1 in al) 
    mul dh    ; Multiply the first number by 10 (AX=AL*DH, so in AX now there's 10) 
    add al,ch ; And add the second number (so that we get 12)
    mov bh,al ; In this way we have the hour in bh
     
                                                                             
minutes:                         

    mov ah,1  ; We use the same approach here to read minutes 
    int 21h   ; Ask for the first number
    sub al,48 ; Convert it in decimal
    mov cl,al ; Copy it in cl
    int 21h   ; Ask for the second number
    sub al,48 ; Convert it in decimal
    mov ch,al ; Copy it in ch
    mov ax,0  ; Reset ax
    mov al,cl ; Copy the first number in al
    mul dh    ; Multiply it by 10
    add al,ch ; Add to it the second number
    mov bl,al ; In this way we have minutes in bl                                           
    
    pop cx        ; Pop cx from the stack
    pop ax        ; Pop ax from the stack
    call new_line ; To print a new line         
    ret           ; end the procedure
read_time endp  


 ; simple procedure to print a new line  
  new_line proc Near
              
               push ax   ; Save value of ax in the stack
               push dx   ; Save value of dx in the stack
                       
               mov dx,13 ; This values in dx are necessary
               mov ah,2  ; to print a new line   
               int 21h  
               mov dx,10
               int 21h 
               
               pop dx   ; Restore dx value by popping it from the stack
               pop ax   ; Restore ax value by popping it from the stack    
              
              ret 
   new_line endp


end