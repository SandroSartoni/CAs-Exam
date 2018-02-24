
; Solution provided by Briand Wamba Foukmeniok
;
;**********************************************************************************************************************************
;
;Exam's text:
;
;A University soccer tournament accounts 9 teams grouped in 3 sets (A, B, C), each one hosting 3 teams, named A1, A2, A3 for
;set A, B1, B2, B3 for set B, and C1, C2, C3 for set C. During the first round, each team same plays two games against the other
;two in the set and a victory is awarded 3 points, a draw with goals is awarded 2 points to each team, a draw without goals
;is awarded 1 point to each team and a loss 0 points. After the first round the top teams of each set are admitted to the second
;round, plus the “best” team of the second classified, i.e. the second classified with more points. These four teams play one
;versus the other this way: Winner of set A vs. Winner of set B and Winner of set C vs. the best second classified. The winners
;of the two games (no tie is possible) play the final and the winner of the final is the winner of the University championship.
;
;It is requested to write an 8086 assembly program to manage the tournament games and rules, based on the scores that are
;received in input by the user. In particular, for each group, the program should present the user with the names of the two
;teams and the user has to enter the score (assuming that no team can score more than 9 goals in a single match). The program
;should compute and present the standings for each group at the end of the first round, together with the names of the teams
;which are admitted to the second round. Then, the program has to present the second round games, receive the results and
;identify the two teams, which will play the final. Lastly, the programs should present the two names of these two teams, playing
;the final and, based on the result received in input, present the winner of the tournament. For example:
;
;A1-A2 = 0-0; A1-A3 = 0-1; A3-A2 = 1-1; leads to the standings: A3 = 5 points; A2 = 3 points; A1 = 1 point
;B1-B2 = 2-0; B1-B3 = 2-1; B3-B2 = 1-1; leads to the standings: B1 = 6 points; B2 = 2 points; B3 = 2 points
;C1-C2 = 4-0; C1-C3 = 4-0; C3-C2 = 0-0; leads to the standings: C1 = 6 points; C2 = 1 point; C3 = 1 point
;
;The winners are, A3, B1, and C1, while the second best classified is A2. Therefore, second round games are: A3-B1, and C1-A2.
;Assume that A3-B1 = 0-1, and C1-A2 = 3-4, then the final will be B1 versus A2; assuming that B1-A2 = 4-5, then the winner of the
;tournament will be team A3.
;
;In the previous example, the identification of the teams admitted to second round is very easy as there have been no ties
;in the number of points awarded. It is ensured that no three-teams ties will occur. The rules in case of a two-teams tie are as
;follows (TIE BREAKER RULES):
;1.	The tie is won by the team with the lowest alphabetical letter;
;2.	In case of further tie, the tie is won by the team with the lowest subscript.
;
;For example: with the previous score, for group B, both B2 and B3 have 2 points and so the question is: which is the second
;classified in the set? According to rule #2, B2 is the second classified because it has a lower subscript (rule #1 has no
;effect here). For group C, both C2 and C3 have 1 point and according rule #2 the second classified is C2.
;
;Please observe that rule #2 can solve a tie inside a group, while rule #1 solves the ties across groups. For example, assuming
;that the three second classified are A3=2 points, B2=3 points, C2=3 points, then, out of B2 and C2, rule #1 decides the
;tie, in favor of B2.
;
;Tasks to be implemented and corresponding point (only fully completed items will be considered to award points)
;•	Item 1 (MANDATORY): write a running program fully implementing the first round ONLY and computing the standings after the
;			        first round. In case of two teams with the same number of points inside a group, any ranking of the two
;			        is acceptable. POINTS -> 22
;•	Item 2: in addition to Item 1, write a running program implementing the TIE BREAKER RULE #2 inside each group to determine
;		    each group standings; POINTS -> +3
;•	Item 3: in addition to Item 2 (and 1), write a running program identifying the best second classified to be admitted to the
;		    second round, according to the following criteria: largest number of points, and, in case of a tie between two
;		    teams, TIE BREAKER RULE #1. POINTS -> +4
;•	Item 4: in addition to Item 3 (and 2), write a running program implementing the second and third (i.e. final) rounds, and
;		    identifying the winning team of the tournament, POINTS -> +4
;•	Bonus Item: in addition to Item 1, write a running program identifying ALL the teams (which could also be more than one) which
;		        have score the largest number of goals at the end of first round. POINTS -> +4 (identifying only one of the many
;		        awards at most 2 extra points).
;Please consider that a maximum of 33 points can be accounted here; larger values will be “cut off” to 33.
;
;HINTS (observe that)
;•	It is ensured that no three-teams ties will occur 
;•	It is advised to design the program as a collection of modules, each one implementing the different Items.
;
;REQUIREMENTS (SHARP)
;•	It is not required to provide the optimal (shortest, most efficient, fastest) solution, but a working and clear one. 
;•	It is required to write at class time a short and clear explanation of the algorithm used.
;•	It is required to write at class time significant comments to the instructions.
;•	Input-output is not necessary in class-developed solution, but its implementation is mandatory for the oral exam.
;•	Minimum score to “pass” this part is 15 (to be averaged with second part and to yield a value at least 18)
;
;REQUIREMENTS ON THE I/O PART TO BE DONE AT HOME
;•	The databases (if any, i.e. not necessary in case) have to be defined and initialized inside the code 
;•	All inputs and outputs should be in readable ASCII form (no binary is permitted).
;
;*********************************************************************************************************************************       
,
;How to get this file running on Ubuntu with NASM:
;  Type: sudo apt-get install nasm
;  Next, type: nasm -f elf64 -o football.o football.asm , and then: ld -o football football.o 
;  In order to run the program, type: ./football

section .data

   sf db "This is the semi-final ."     ;i use that just to clean the program 
   s  db "This is the final ."          ;i use that just to clean the program 
   w  db "The winner is    ."              ;i use that just to clean the program
   g  db "Group   ."
   cg db "Final classification of group   ."

   s1 db 'A','1','A','2','A','3'
   s2 db 'B','1','B','2','B','3'
   s3 db 'C','1','C','2','C','3'
   p1   db 0,0,0
   p2   db 0,0,0
   p3   db 0,0,0   
   tmp db '-'          

aa db 10
daa : equ 1
dim : equ 3

section .bss

var resb 8
score resd 8

section .text
 
    global _start:

_start:

  mov byte[g+7],'A'  ; I set the seventh byte pointer by g in A
  mov ecx,g          ; I move the effective address of g i put it in register rcx
  call _printline    ; I call my procedure
  call _newLine      ; I call my procedure

  mov rdi ,s1        ; I move the offset of s1 i put it in register rdi
  mov rsi ,p1        ; I move the offset of p1 i put it in register rsi
  call _scan         ; i call procedure _scan
  mov rdi ,s1        ; I move the effective address of s1 I put it in register rdi
  mov rsi ,p1        ; I move the effective address of p1 I put it in register rsi
  call _sort   
  mov rdi ,s1        ; I move the offset of s1 i put it in register rdi
  mov rsi ,p1        ; I move the offset of p1 i put it in register rsi

  mov byte[cg+31],'A'; I set the seventh byte pointer by cg in A  
  mov ecx,cg         ; I move the effective address of cg I put it in register rcx
  call _printline    ; I call this procedure just for presentation 
  call _newLine
  call _stampagroup  ; I will stamp all information of group
 

  mov byte[g+7],'B'  ; equal like previous operations
  mov ecx,g  
  call _printline  
   call _newLine
  mov rdi ,s2        ; I move the offset of s2 i put it in register rdi
  mov rsi ,p2        ; I move the offset of p2 i put it in register rsi
  call _scan         ; allow to get scoore of taem of the group
  mov rdi ,s2        ; I move the offset of s2 i put it in register rdi
  mov rsi ,p2        ; I move the offset of p2 i put it in register rsi
  call _sort 
  mov rdi ,s2        ; I move the offset of s2 i put it in register rdi
  mov rsi ,p2        ; I move the offset of p2 i put it in register rsi

  mov byte[cg+31],'B' ; I set the seventh byte pointer by cg in B 
  mov ecx,cg         ; I move the effective address of cg I put it in register rcx
  call _printline    ; I call this procedure just for presentation 
  call _newLine
  call _stampagroup  ; I will stamp all information of group

  mov byte[g+7],'C'  ; equal like previous operations
  mov ecx,g  
  call _printline    ; just for presentation
   call _newLine     ; just for presentation

  mov rdi ,s3          ; I move the offset of S3 i put it in register rdi
  mov rsi ,p3          ; I move the offset of p3 i put it in register rsi
  call _scan 
  mov rdi ,s3          ; I move the offset of s3 i put it in register rdi
  mov rsi ,p3          ; I move the offset of p3 i put it in register rsi  
  call _sort 
  mov rdi ,s3          ; I move the offset of s3 i put it in register rdi
  mov rsi ,p3          ; I move the offset of p3 i put it in register rsi


  mov byte[cg+31],'C' ; I set the seventh byte pointer by cg in C
  mov ecx,cg         ; I move the effective address of cg I put it in register rcx
  call _printline    ; I call this procedure just for presentation 
  call _newLine
  call _stampagroup  ; I will stamp all information of group
                     ; I assume that the second of group A is my 4th for the semi final
  mov ax,word[s1+2]  ;I load 2byte="word" starting at the 2nd byte of vector s1 
  mov cl,byte[p1+1]  ;I load 1byte placed at the 2nd position of vectora p1
  
  cmp cl,byte[p2+1]  ; I compere mark value store in cl( dimension 1 byte) with the second byte( mark of second in group B)of vector p2
  jge nothing11      ; jump in (label) nothing11 if cl>=byte[p2+1]; cmp set a flag
  mov ax,word[s2+2]  ; I load the value of second element of vector s2 into ax,  I add 2 because 1 element(name) is represent by 2byte=word
  mov cl,byte[p2+1]  ; I load the value of second element of vector p2 into ax
  nothing11:
  cmp cl,byte[p3+1]  
  jge nothing22
  mov ax,word[s3+2]
  nothing22:

  mov ecx,sf         ; I load the offset of sf into rcx  
  call _printline    ; i print the message contains into vector sf
  call _newLine

  push rax           ; I save into a stack the value of rax (name of 4th )
  mov ax,word[s1]    ; I take the firs of group A ; Load into ax the first 2byte(word) of vector s1
  mov bx,word[s2]    ; I take the firs of group B ; Load into bx the first 2byte(word) of vector s2
  call _semi         ; I will make the match between these  2 squares
  pop rbx            ; I retrieve my 4th , taking it into the stack by operation pop
  push rax           ; I save into the stack my first team qualificated for  the final( obtain after calling _semi) 
  mov ax,word[s3]    ; I take the first of group C i will confront ( _semi) againt the fourth
  call _semi
  mov bx,ax         ; I put ax into bx
  pop rax           ; I take my first first finalist

  mov ecx,s  
  call _printline   ; just for presentation
  call _newLine     ; just for presentation

  call _semi      

  mov ecx,w           ; just for presentation
  mov word[w+14],ax  
  call _printline     ; just for presentation     
  call _newLine       ; just for presentation
  
   mov eax,1
   mov ebx,0
   int 80h
;******************************
_semi:             ;it take 2 parameters( name of team) into registers rax and rbx and return set into rax the winner between them

    mov rdx,rax
    push rax          ; I save value(team name ) into stack because i  will overwrite the register into procedure getscore

    mov rcx,var       ; I move offset of var( temporaly variable) 
    mov [rcx],dx      ; I load the value of dx(team name) into memory pointer by rcx ( var); [rcx]=memory that offset is in rcx  
    call _printname   
    mov rcx ,tmp      ; I load offset of tmp into rcx ; I want to print the caracter '-'
    call _printchar
    mov rcx,var     
    mov [rcx],bx       ; I load the value of dx(team name) into memory pointer by rcx ( var); [rcx]=memory that offset is in rcx  
    call _printname

    call _space      ; I call this procedure (_space) to print soma space before ask score
    call _getscore   ; getscore return  score into ah and al  

    cmp ah,al        ; I compere the risult and I put the winner into rax
    jl  w_bx         ; if ah<al I jump on w_bx( winner is bx)
    pop rax          ; else I pop rax ( my winner )
    jmp end_s        ; I jump at the end of procedure
w_bx:
    pop rdx           ; I retrieve value of rdx 
    mov ax,bx         ; I load value of bx in ax
end_s:
ret                 ; directive to return in the caller procedure or function

; ****************************
_sort:

mov rcx,0            ; I set rcx in 0 ; they are my index i(cl) and j (ch)
mov rdx,rdi          ; I

ii_i: cmp cl,dim    ; If i==dim 
      je end_i      ; If cl == dim I jump on label end_i end of extern cicle 
         
      mov ch,cl     ; I move index j=i ( cl=ch )
      inc ch          ;j=j+1 I increment cl because I want to campare element i with element j=i+1 ... 
      mov bh,[rsi]    ; I load into bh 1byte (point) value of element i 
      mov rdi, rsi    
      inc rdi         ;like j=j+1 

jj_j: cmp ch,dim      ; I compere j with dim
      je end_j        ; If (ch==dim) they are equal I stop my cicle
      
      mov bl,[rdi]    ;I load into bl value of j ( rdi contains offeset of point vector)
      cmp bh,bl       ; I compare bh with bl 
      jg  nextt       ; If  bh is grether than bl I jump on lebel nextt
      cmp bh,bl       ; I compare bh with bl
      jl  swap        ;If  bh is less than bl I jump on lebel swap
check_name:
      push rdi        ;I save rdi into the stack ( offset of point (i) )
      push rsi        ;I save rsi into the stack ( offset of point (j) )
      mov rdi,rdx     ;I put rdx into rdi (rdx contains offset of name )
      mov rsi,rdx     ;I put rdx into rsi (rdx contains offset of name )
      mov rax,0
      mov al,cl       ; I mov  cl into al (al=i)
      add rsi,rax     ; I want to make the displacement  ( rsi=rsi+rax = s1[0+i])
      add rsi,rax     ; I add rax 2times because the vector take 2byte(word) for element
      mov al,ch       ; I mov ch into al ( al=j)
      add rdi,rax     ; I want to make the displacement  ( rdi=rdi+rax = s1[0+j]) 
      add rdi,rax     ; I add rax 2times because the vector take 2byte(word) for element
      mov ax,word[rsi] ; Ax= s1[i] ; 
      
      cmp ax,word[rdi] ; I compare ax ( S1[i]) with value that address is store in rdi (S1[j])
      jl  nothing      ; If ax is less than [rdi] I jump on label nothing
      pop rsi          ;I retrieve my value into stack  
      pop rdi
      jmp swap         ; I jump on label swap
nothing:
       pop rsi         ; I retrieve my values into stack
       pop rdi        
       jmp nextt       ; I jump on label nextt

swap: push rdi         ; I save positon i  into vector mark
      push rsi         ; I save positon i  into vector mark
      mov rdi,rdx      ; I move offset of team name int rdi
      mov rsi,rdx      ; I move offset of team name int rdi
      mov rax,0        
      mov al,cl        ; into al I put cl = i
      add rsi,rax      ; I make displacement 
      add rsi,rax      ; I make displacement   because names rae on 2 byte
      mov rax,0
      mov al,ch        ; into al I put cl = i
      add rdi,rax      ; I make displacement  
      add rdi,rax      ; I make displacement   because names rae on 2 byte
      mov ax,word[rsi]  ; I wsap thier value ( name )
     xchg ax,word[rdi]  ; I wsap thier value ( name )  
     xchg ax,word[rsi]  ; I wsap thier value ( name )   
       pop rsi        ; I retreive  my mark vector  (team i)
       pop rdi        ; I retreive  my mark vector ( team j)
      mov [rdi],bh    ; I update  the mark 
      mov [rsi],bl    ; I update  the mark 
      mov bh,bl       ; I update  the mark 
        
nextt:
     inc ch           ; I increment index j
     inc rdi          ; I  increment displamenet  
     jmp jj_j         ; I jump on loop jj_j cicle heading by index j

end_j:
      inc rsi
      inc cl          ; I increment index i
     jmp ii_i         ; I jump on loop ii_i cicle heading by index i
     
end_i:
   
ret

;*****************
_stampagroup:
    push rcx            ;I save into stack the value of rbx
    mov rcx,0           ; I put into rcx value 0 I will use it like my index

start1:
    cmp cx,dim          ; I compare cx with dim ( number of team ) 
    je end3             ; If I already print all team I stop -> if cx==dim I jump on lebal end3
    push rcx            ; I save rcx into stack .it is my index 
    mov rcx,rdi         ; I move rdi( offset of name team ) into rcx so rcx point of one team name
    call _printname     ; I will print this name team
    call _space         ; print some space 
    mov rcx,rsi         ; I move rsi( offset of point team ) into rcx so rcx point of one team point
    mov al,byte[rcx]    ; I take the number of point
    mov [score],al      ; I save into tmp variable
    add byte[score],48  ; I will add 48 to convert like char ascii...
    mov rcx,score       ; I put into rcx offset of tmp variable
    call _printchar     ; I call print char
    add rdi,2           ; I add 2 on rdi because one name occupe 2 byte
    inc rsi             ; I add 1 on rsi because one point team occupe 1 byte
    pop rcx             ; I take my index rcx into stack
    inc cx              ; I increment it cx = cx+1
    call _newLine       ; semple for presentation
    jmp start1          
end3:
pop rcx                   

ret
;***********
_space:
push rcx                ;I save into stack the value of rcx 
mov word[score],"  "    ;I put space scoore just for presentation
mov rcx,score           ; I put offset of score into rcx
call _printname         ; I print the space
pop rcx               
ret
;*********************************
_scan:
mov rcx,0   
mov rbx,rsi              ; in rbx i have offset of ppoint
i_i:
cmp cx,dim               ; I compare cx with dim ( number of team ) 
    je end1
    push rcx             ; I save rcx into stack .it is my index  i
    
mov rsi,rdi             ; I put rdi into rsi
    add rsi,2           ; I add 2 on rsi for go to the next team
    inc cx              ; I increment cx according to next team

j_j: cmp cx,dim          ; I compare cx with dim ( number of team ) 
    je end2              ; if I alway make all combination with team i an team j=i+1 .... dim i stop and repeat with team i+1
    push rcx             ; I save rcx into stack .it is my index  J
    mov rcx,rdi          ; I move offset of team name i
    call _printname      ; I print the name of team i
    mov rcx ,tmp         ; just symbol of presentation
    call _printchar      ; just for presentation
    mov rcx,rsi          ; I move offset of team name j
    call _printname      ; I print hte name of team j
    
    call _space          ; just for presentation       
    call _getscore       ; in score ah and al
        
    pop rcx              ; I take into stack my index j
    pop r10              ; I take into stack my index i
    push r10             ; I save r10 into stack .it is my index  i
    push rsi             ;  ; I save rsi into stack .it is name of team 1
    push rdi             ;  ; I save rdi into stack .it is name of team 2
    mov rdi,r10         ; I put i into rdi 
    mov rsi,rcx         ; I put j into rsi 
    add rsi,rbx         ; I add offset of mark vector to retreive mark of team i
    add rdi,rbx         ; I add offset of mark vector to retreive mark of team j 
    
    cmp ah,al           ; I compare the score
    je  equall          ; if is equal I check if they dis 0-0 or 1-1...
    cmp ah,al           ; else I will assign 3 mark to the winner
    jg  mark_3_0        ; if team i win i jump on label mark3_0 and add it 3 point

mark_0_3: add byte[rsi],3           ; else I add to the second team j
          jmp already_give_mark     ; I jump on already
          
equall: cmp al,'0'                  ; If is equal I check if is 0-0 like that I will add 1 mark to each
        je mark_1_1                 ; If is equal I check if is 0-0 like that I will add 1 mark to each
mark_2_2: add byte[rsi],2           ; else I add 2 mark to each
          add byte[rdi],2
          jmp already_give_mark
mark_1_1: add byte[rsi],1          ; I add 1 mark  to team j
          add byte[rdi],1          ; I add 1 mark  to team i
          jmp already_give_mark
mark_3_0: add byte[rdi],3          ;I add 3 mark  to team first team i
          jmp already_give_mark

already_give_mark:
    pop rdi                        ; I retrieve my name i on the stackk
    pop rsi                        ; I retrieve my name j on the stackk

    inc cx                         ; I increment j so i pass to team j+1
    add rsi,2                      ; I increment team j so I pass to team j+1
    jmp j_j
end2:   
    pop rcx                        ; I retrieve my index i on the stackk
    inc cx                         ; I increment i so I pass to team i+1
    add rdi,2                      ; I increment team i so I pass to team i+1
    jmp i_i    
end1:

ret 
;*******************
_getscore:
  
   push rdi         ; I save rax into stack because i will use it here
   push rsi         ; I save rax into stack because i will use it here
   push rbx         ; I save rax into stack because i will use it here
   
   mov rax,0        ; I calling system call READ , puting 0 into rax
   mov rdi,0        ; 0 into rdi standar input keybord
   mov rsi,score    ; I will save into variable score 
   mov rdx,6        ; I will read at most 6 byte
   syscall          ; with the previous intruction I will call  syscall read

   pop rbx          ; I take my value into stack
   pop rsi          ; I take my value into stack
   pop rdi          ; I take my value into stack
   mov ah,[score]   ; put the first carater corisponding to the number of goal of first team
   mov al,[score+2] ; put the second carater corisponding to the number of goal of second team
    
ret

;*****************************
_printname:
call _printchar    ; I print the first carater
inc rcx            ; I increment to past to the second carater
call _printchar    ; I print the second carater
ret

;***************************** put offset of vector in ecx 
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
;************************* char is stored in ecx
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


