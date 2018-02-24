section .data


 tab_a dw 080Ah,0900h,092Dh,0A1Eh,0B1Eh,0C1Eh,0D0Fh,0E00h,0F00h,1000h,1100h,1200h
 tab_b dw 070Ah,080Fh,0905h,0A28h,0B00h,0E00h,0E1Eh,0F00h,0F1Eh,100Fh,102Dh,110Fh
 tab_c dw 081Eh,0928h,0A32h,0C00h,0D0Ah,0E14h,0F1Eh,1028h,1132h,1300h,140Ah,1514h
 tab_d dw 0700h,0828h,0928h,0A28h,0B28h,0C1Eh,0D1Eh,0F00h,101Eh,121Eh,141Eh,1500h


sms: db "Insert departure time: ." 
sms1: db "The first available bus is at: ."
sms2: db "First street ."
sms3: db "I will arrive at swap point at : ."
sms4: db "I will leave the swap point at : ."
sms5: db "I will arrive  at the office at : ."
sms6: db "Second street ."
sms7: db "Total duration of travel is ."

  a_to_b dw 16
  b_to_tp dw 29
  c_to_d dw 4
  d_to_tp dw 45 

aa db 10             ; Just for print new line
dim : equ 12         ; length of my tables

section .bss

flag1 resb 8
flag resb 8
var resb 8
dure1 resb 8
dure2 resb 8
strr resb  10
time resb  8

section .text
 
    global _start:

_start:
    
    mov ecx,sms        ; I load offset of sms
    call _printline    ; I call this procedure to print it    
    call _readHour     ; I read the time by this procedure I will ahve my departure time into ax

    mov ecx,sms2        ; I load offset of sms
    call _printline     ; I call this procedure to print it
    call _newLine       ; I call this procedure to print new line
     
    mov bx,ax           ; I mov ax into bx ( departure time )
    push rbx            ; I save departure time in the stake. after I will use it for calculation of second street
    mov rdi,tab_a       ; I put offset of tab_a into rdi
    mov rsi,tab_b       ; I put offset of tab_b into rsi
    mov r11w,[a_to_b]   ; I am taking the value save into a_to_b
    mov [dure1],r11w    ; I save into variable dure1
    mov r12w,[b_to_tp]  ; I am taking the value save into b_to_tp
    mov [dure2],r12w    ; I save into variable dure2
    call _percorso      ;passing parameter
    call _newLine

    mov ecx,flag           ; I set flags 
    mov byte[ecx],0        ; flag=1 if i will arrive the next day
    mov ecx,flag1          ; flag1=1 if i could already print the time with *
    mov byte[ecx],0

    
    mov ecx,sms6       ; I load offset of sms
    call _printline    ; I call this procedure to print it
    call _newLine      ; I call this procedure to print new line

    pop rbx             ; I take into stack my  departure time
    mov rdi,tab_c       ; I put offset of tab_c into rdi
    mov rsi,tab_d       ; I put offset of tab_d into rsi   
    mov r11w,[c_to_d]   ; I am taking the value save into c_to_d
    mov [dure1],r11w    ; I save into variable dure1
    mov r12w,[d_to_tp]  ; I am taking the value save into d_to_tp
    mov [dure2],r12w    ; I save into variable dure2
    call _percorso  
    call _newLine    


   mov eax,1
   mov ebx,0
   int 80h
;*********************************
_readHour:

   mov rax,0       ; I calling system call READ , puting 0 into rax
   mov rdi,0       ; 0 into rdi standar input keybord
   mov rsi,time    ; I will save into variable time 
   mov rdx,6       ; I will read at most 6 byte
   syscall         ; with the previous intruction I will call  syscall read
   
   mov rbx,10    
   mov ecx,time

   mov al,byte[ecx] ; I move the first caracter corrisponding to the 1hour caracter
   sub al,48        ; I move 48 to convert it to an integer 
   mul rbx          ; I multiplicate it by 10
   inc ecx
   mov dl,byte[ecx] ; I move the second caracter corrisponding to the 2hour caracter
   sub dl,48        ; I move 48 to convert it to an integer 
   add al,dl        ; now I have my time hour

   add ecx,2        ; I will ignore the caratere 'H' insert just for presentation
   push rax         ; i save hh  into stack
   
   mov al,byte[ecx] ; I move the 4th caracter corrisponding to the 1minute caracter
   sub al,48        ; I move 48 to convert it to an integer
   mul rbx          ; I multiplicate it by 10
   inc ecx
   mov dl,byte[ecx] ; I move the 5th caracter corrisponding to the 2minute caracter
   sub dl,48        ; I move 48 to convert it to an integer
   add al,dl        ; now I have my minute time       
   
   pop rdx
   mov ah,dl        ; now I have my departure time into ax like AX=HHmm

ret 


;**************************

;tab_a =rdi tab_b=rsi  partentenza =bx ,dure1= a_to_b   dure2=b_to_tp
_percorso:
    push rbx          ;I save into stack the value of rbx ( is my departure time )

    call _find        ;I want to find the first available bus ( I have the offset of table hour in rdi)
    mov ecx,sms1      ;I mov the offset of sms1 (first available ... ) into rcx
    call _printline   ;I call procedure printline to print my sms where offset is into rex 
    mov ax,[rdi]      ;I take the time calculare by procedure find 
    call _print_time  ;I print the time that value is constiant into register ax      
    call _addTime     ;This procedure compute the following operation  ax=ax+a_to_b  
    mov ecx,sms3      ;I mov the offset of sms3 (I will arrive at ... ) into rcx
    call _printline   ;I call procedure printline to print my sms where offset is into rex 
    call _print_time  ;I print the time that value is constiant into register ax 
    
    mov bx,ax         ;I put into bx contians of ax 

    mov rdi,rsi       ;I put into rdi contians of rsi ( offset of second hour table ) 
    call _find        ;I want to find the first available bus ( I have the offset of table hour in rdi)
    mov ecx,sms1      ;I mov the offset of sms1 (first available ... ) into rcx
    call _printline   ;I call procedure printline to print my sms where offset is into rex 
    mov ax,[rdi]      ;I take the time calculare by procedure find
    call _print_time  ;I print the time that value is constiant into register ax
    mov r11w,[dure2]
    mov [dure1],r11         ; prepare dure1
    call _addTime     ;This procedure compute the following operation  ax=ax+swap_to_office  
    
    mov ecx,flag1     ; I put offset of flag1 into ecx
    mov byte[ecx],1   ; I set my flag1 in 1 ( allows to print the '*' ) because if flag1==1 I could print '*' accordind with flag0
    mov ecx,sms5      ;I mov the offset of sms5 (i arrive at office at ... ) into rcx
    call _printline   ;I call procedure printline to print my sms5 where offset is into rex     
    call _print_time  ;I print the time that value is constiant into register ax

    pop rbx           ;I take my departure time into the stack 
 
    mov ecx,flag1     ; I put offset of flag1 into ecx
    mov byte[ecx],0   ; I set my flag1 in 0  because if flag1==0 I could not print '*' independing of flag0
    call _subHour     ; total duration = arriveH - leaveH  +flag*24 ( I have tis risutl in ax)
    mov ecx,sms7      ;I mov the offset of sms7 (total duration ... ) into rcx
    call _printline   ;I call procedure printline to print my sms5 where offset is into rex      
    call _print_time  ;I print the time that value is constiant into register ax  
  
ret 

;++++++++++++++++++++++
 ; ax=ax-bx = arriveH - leaveH  +flag*24
_subHour: 

mov r10b,1            ;I move 1 into register r10b     
cmp [flag],r10b       ;I compare  flag with r10b 
jne nothing2          ;
add ah,24             ; If flag==1 I add 24 in my total duration
nothing2:

cmp al,bl             ;I compare  bl with al ( minute )
jge nothing1          ; if (bl( depart minute ) <al( arrive minute) ) i make normaly al-bl
dec ah                ; Else I decrement  1h in (ah arrive hour ) 
add al,60             ; I add 60 minute al=al+60
nothing1:             
sub al,bl             ; al = al-bl ( rest of minute)
sub ah,bh             ; ah = ah-bh ( rest of hour ) in ax i have the duration of travel

ret
;***********************************  
_addTime:  ; ax=ax+t

add al,byte[dure1]  ; dure1 is variable that contains time necesary for bus to go from  place to another
cmp al,60           ; if I the sommation of minutes is more 60 minutes
jl nothing
inc ah              ; I add 1hour by incrementing ah  
sub al,60           ; and I sustract 60 minutes
nothing:

ret 

;****************************** n , flag , ecx=vet 
_find:

push rsi                  ; I save rsi into stack 
mov esi,edi               ; I mov edi into esi ( offset of table hour so position of first hour )
mov rcx,0                 ; I put 0 into rcx I use  it like my index

ciclo1: cmp cx,dim        ; I i check into all the table and I didn't find availbale time 
        je next_day       ; I jump on label next_day ;I could take it only next day  
        cmp [edi],bx      ; I compare bx ( departime time ) with  time in my hour table  
        jge stopp         ; If one time in my table hour is >= of departure time  => I find my available time 
        add edi,2         ; else I move on the next time  edi = edi+2 because hour is represent on 2 byte
        inc cx            ; I increment my index cx=cx+1 
        jmp ciclo1  
        
next_day: mov edi,esi     ; I take the available time in edi
          mov ecx,flag    
          mov byte[ecx],1 ; I set my flag with value 1
stopp:  mov ax,[edi]      ; I move into ax the time of first available bus
      
pop rsi
ret  ; at the end i have available hour in ax 

;***************************** put offset of line in ecx 
_printline:
   push rax                   ; I save rax into stack because i will use it here
   mov al,'.'                 ; I puut the end contidion of line here
  ciclo: cmp byte[rcx], al    ; if it is the end condition I stop   
         je fine
         call _printchar      ; else I print the carater that offset is in rcx    
         inc rcx              ; I go to the next caracter
         jmp ciclo            ; I jump on label cicle
  fine: 
    pop rax                   ; I take my value into stack
ret 
;************************* offset of char is stored in rcx
_printchar:
     push rax        ; I save rax into stack because i will use it here
     push rbx        ; I save rax into stack because i will use it here
     push rdx        ; I save rax into stack because i will use it here
      mov eax,4      ;*** system call print    
      mov ebx,1      ;*** where I want to print 1= standard output
      mov edx,1      ;*** number of caracter i want to print
      int 80h        ;*** these are operation to print caracter dimention cchoose freely In our case is just 1
    pop rdx           ; I take my value into stack
    pop rbx           ; I take my value into stack
    pop rax           ; I take my value into stack
ret 
;***********************
_newLine:             ; I save rax into stack because i will use it here
push rcx            
mov ecx,aa            ; I move offset of aa into ecx ( value of aa is 10 ) equal to caracter new line
call _printchar       ; print caracter
pop rcx               ; I take my value into stack
ret

;*********************
_print_time: ; i have my time in ax
   ;exemple  ah=11 and al=30 ( ax=1130) -> i want to have 11H30 on the display 

mov rcx,strr       ; my string (strr) has lengh 8 byte I move the offset into rcx
add rcx ,7         ; I move rcx in the 7th position 

mov dl,'.'         ; I put the end line because after i will use printline into dl
mov [rcx],dl       ; I put the end line because after i will use printline into strr[7]
dec rcx

push rax          ; I save rax into stack because i will use it here for arimetic operation
mov ah,0          ; I put 0 into ah so ( I just have now minute into ax )    ** here ax become ax=0030

mov rbx,10        ; I put 10 into rbx
mov rdx,0         ; I put 0 into rdx
div rbx           ; rax= rax/rbx ( interger part of division)  and rdx=rax % rbx ( rest of division )
                  ; rax ( 3 )= rax ( 30 ) / rbx (10 ) and rdx (0)= rax(30)% rbx(10)
add rax,48        ; I convert to it corrispondi assci value
add rdx,48        ; I convert to it corrispondi assci value

mov [rcx],dl      ; I put the rest in the last position ---strr[6]=0
dec rcx           ; I decrement my position             
mov [rcx],al      ; I put the division                 ----strr[5]=3
dec rcx           ; I decrement to the next position 

pop rax           ; I thake my time                            ** here ax become ax=1130
push rax          ; I save it again

mov dl,'H'        ; I put the carater H for presention   ..H..
mov [rcx],dl      ; I put H into                        ----strr[4]=H
dec rcx           ; I decrement to the next position        
mov al,ah         ; I put the hours (ah ) into al               ** here ax become ax=1111
mov ah,0          ; I put 0 in  ah                              ** here ax become ax=0011
                  ; I repet the previows way that I did on the minute 
mov rdx,0      
div rbx           ; rax ( 1 )= rax ( 11 ) / rbx (10 ) and rdx (1)= rax(11)% rbx(10)  
add rax,48
add rdx,48

mov [rcx],dl               ;---strr[3]=1
dec rcx
mov [rcx],al               ;---strr[2]=1 
dec rcx            

call _printline        ; rcx point of the first position of vector strr and I print it

mov al,1
cmp al,[flag1]         ; Compare flag1 with 1 if falg1==1 I am arrive at the office I could print '*'
jne nothing3           ; Else I could not print ; now I check if flag == 1
cmp al,[flag]          ; Compare flag with 1 if falg==1 
jne nothing3           ; Else I dont do something
mov byte[ecx],'*'      ; I put the '*' into strr[1] 
call _printchar        ; I print it
nothing3:

call _newLine          ; Just for presentation

pop rax

ret




