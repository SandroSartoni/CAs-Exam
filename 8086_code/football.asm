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
;			        is acceptable. POINTS  22
;•	Item 2: in addition to Item 1, write a running program implementing the TIE BREAKER RULE #2 inside each group to determine
;		    each group standings; POINTS  +3
;•	Item 3: in addition to Item 2 (and 1), write a running program identifying the best second classified to be admitted to the
;		    second round, according to the following criteria: largest number of points, and, in case of a tie between two
;		    teams, TIE BREAKER RULE #1. POINTS  +4
;•	Item 4: in addition to Item 3 (and 2), write a running program implementing the second and third (i.e. final) rounds, and
;		    identifying the winning team of the tournament, POINTS  +4
;•	Bonus Item: in addition to Item 1, write a running program identifying ALL the teams (which could also be more than one) which
;		        have score the largest number of goals at the end of first round. POINTS  +4 (identifying only one of the many
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
;How to get this file running emu8086:
;  Simply load this file and then click Emulate, many windows will open with the possibility of debugging and checking everything
;How to get this file running with MASM:
;  Download MASM and DOSBox at the link: https://mega.nz/#!4exx2KZI!gnlI4rPvYBhElE-y_k-p9GtBfw550U82ZFB-lHqZJho
;  Install DOSBox and move the directory named "8086" in C: folder. Copy in 8086 folder this executable
;  Once in DOSBox, type first " mount c: c:\8086", then "c: ", next "ml filename.asm" and finally "filename.exe"


N equ 3                              ; Define a constant named N and equal to 3

.model small
.stack
.data                                ; Here, start defining data in memory
   s1 db 'A','1','A','2','A','3'     ; Group A
   p1  db 0,0,0                      ; Points of group A
   s2 db 'B','1','B','2','B','3'     ; Group B
   p2   db 0,0,0                     ; Points of group B
   s3 db 'C','1','C','2','C','3'     ; Group C
   p3   db 0,0,0                     ; Points of group C
   sf db "This is the semi-final ."  ; String to tell the user semifinals are playing 
   s db "This is the final ."        ; String to tell the user final is playing 
   w db "The winner is ."            ; String to tell the user who's the winner
   g db "Group   ."                  ; String to tell the user which group is playing
   cg db "Final ranking of group   ."   ; String to tell the user the ranking
   
.code
.startup
          
          
          push ax            ; Push in the stack all the registers
          push bx
          push cx
          push dx
          push si
          push di
          push bp 
          
          mov g[6],'A'       ; Copy in Group string 'A', so that it'll print "Group A"
          lea di,g           ; Load g's effective address in di
          call print_line    ; Call the procedure print_line     
          
          lea di,s1          ; Load in di the base address of s1                           
          lea dx,p1          ; Load in dx the base address of group A points    
          call get_results   ; Call the procedure to get the results for each group
                                         
          lea bx,p1          ; Load in bx the address of p1
          lea si,s1          ; And in si the address of s1
          call sort          ; In order to sort the group in terms of points     
               
         
          mov cg[23],'A'     ; So that we can print A rankings     
          lea di,cg          ; Get cg's address in di
          call print_line    ; Print that line
          lea si,s1          ; Load in si the first group                    
          lea di,p1          ; Load in di first group's points 
          call print_ranking ; Print ranking
          call new_line      ; Print a new line
                     
          
          mov g[6],'B'       ; Everything that has been done until now will
          lea di,g           ; be repeated for group B and C
          call print_line   
          
          lea di,s2                         
          lea dx,p2         
          call get_results
                                         
          lea bx,p2 
          lea si,s2        
          call sort         
                                 
          
          mov cg[23],'B'     
          lea di,cg     
          call print_line 
          
          lea si,s2                         
          lea di,p2      
          call print_ranking  
          call new_line  
                     
          
          mov g[6],'C'  
          lea di,g      
          call print_line 
                     
                    
          lea di,s3          ; Section related to the third group                   
          lea dx,p3         
          call get_results
                                         
          lea bx,p3 
          lea si,s3        
          call sort                   
                           
          mov cg[23],'C'     
          lea di,cg     
          call print_line 
          lea si,s3                          
          lea di,p3      
          call print_ranking 
          call new_line  
                     
                                    
 ;****************************  In this section we search for the fourth classified

                        
          mov bh,s1[2]     ; Copy in bh 'A'
          mov bl,s1[3]     ; Copy in bl second team's number
          mov cl,p1[1]     ; Copy in cl A second team's points
          cmp cl,p2[1]     ; Compare it with B second team's points
          jnl second_check ; If A's team has more or equal points than B, move forward
          mov bh,s2[2]     ; Otherwise, copy in bh 'B' 
          mov bl,s2[3]     ; And copy in bl the number of the second team
          mov cl,p2[1]     ; In cl, its points
 second_check:         
          cmp cl,p3[1]     ; Compare cl with C second team's points
          jnl keep_on      ; As before, if it's greater or equal, move forward
          mov bh,s3[2]     ; Otherwise, move in bh 'C'
          mov bl,s3[3]     ; And in bl the team's points
          mov cl,p3[1]
 keep_on:                
          mov di,bx        ; Move the fourth in di
          
          mov bh,s1[0]     ; Now move in bx the first 
          mov bl,s1[1]     ; classified of group A
          mov ch,s2[0]     ; And move in cx the first
          mov cl,s2[1]     ; classified of group B
          
;****************************   Section to play the semifinals
                    
          push di           ; Push in the stack the fourth classified      
          lea di,sf         ; Copy in di the semifinal string  
          call print_line   ; And print it
          
          pop di            ; Restore the fourth 
          
          call semi         ; Call this function to play the first semifinal
          mov si,bx         ; Move in si the winner       
                                                          
          mov ch,s3[0]      ; Copy in cx the third  
          mov cl,s3[1]      ; group winner 
           
          mov  bx,di        ; Move in bx the fourth
          call semi         ; Play the second semifinal
     
          mov cx,si         ; Copy the 2nd winner  in cx
          xchg cx,bx        ; First winner vs second winner
                              
;**************************** Play the final
          call new_line     ; Print a new line          
          push di                 
          lea  di,s         ; Load in di the "final" string
          call print_line   ; Print it
          pop  di       
                
          call semi         ; Play the final
          call new_line    
          lea  di,w         ; Load the "winner" string
          call print_line 
;          
          mov ah,2          ; Print the winner    
          mov dl,bh       
          int 21h    
          mov dl,bl      
          int 21h         
                 
         
                     
          pop bp            ; Pop all the previous registers
          pop di
          pop si
          pop dx
          pop cx
          pop bx
          pop ax
           
           
      
.exit                      ; End of the main

     
 ; This is print_line procedure, it's near so it means it belongs to the same code segment     
 print_line proc near
        
            push ax         ; Save ax and cx so that they won't be modified
            push cx
            mov ah,2        ; Copy 2 in ah, used in association with int 21h to print to the screen
            mov cl,'.'      ; To determine when to end the loop
            
  print_string:   
            mov dl,[di]     ; Copy in dl a character from the string     
            cmp dl,cl       ; Check if it's a '.'
            je end_print    ; If so, stop printing and go to end_print    
            int 21h         ; Otherwise, print the character
            inc di          ; Increment di in order to have the next character
            jmp print_string; Keep looping           
                
  end_print:   
            pop cx          ; Restore cx and ax
            pop ax
            call new_line   ; Call the procedure new_line
            
            ret             ; End of the procedure
 print_line endp
                    
      ; Procedure to play the semifinal
      semi proc near
              
          mov ah,2 
          mov dl,bh       ; Print the first semifinalist letter
          int 21h
          mov dl,bl       ; Print the first semifinalist number
          int 21h                                      
          mov dl,'-'      ; Print a '-'
          int 21h                                         
          mov dl,ch       ; Print the second semifinalist letter
          int 21h
          mov dl,cl       ; Print the second semifinalist number
          int 21h
          mov dl," "      ; Print a space
          int 21h
                   
                          
          mov ah,1        ; Ask for the first score
          int 21h
          mov dh,al       ; And copy it in dh                
            
          mov ah,2        ; Print a '-'
          mov dl,'-'
          int 21h             
                    
                          
          mov ah,1        ; Ask for the second score
          int 21h         
          
          cmp dh,al       ; Compare the two scores
          jg first_win     ; If the first team wins, do nothing  
          
          mov bx,cx       ; Else, update the winner
    first_win:            
                          ; At the end the winner is in bx
        call new_line     ; Print a new line
        ret
          
      semi endp         
               
               
               
               
      get_results proc near
                                                
      mov bx,dx           ; Copy in bx the base address of pX (X=1/2/3)
      mov cx,0            ; Reset cx
         
outer_loop: 
          cmp cx,N                  ; Check if we've still to loop
          je  end_matches           ; If cx is equal to N (3) then go to fine  
          push cx                   ; Otherwise, first push cx
          
          inc cx                    ; Increment it       
          mov si,di                 ; Copy in si the base address of sX
          add si,2                  ; si now points to the next team
                          
   nested_loop: cmp cx,N            ; Check if cx is equal to N
                je  end_nested_loop ; If so, end this nested loop                 
                mov ah,2            ; Otherwise, start printing the first team          
                mov dl,[di]         ; Copy in dl the letter    
                int 21h             ; Print it
                inc di              ; Increment di, in order to have the number
                mov dl,[di]         ; Copy it in dl  
                int 21h             ; And print it
                dec di              ; Then, decrement di   
                   
                mov dl, '-'         ; Print the '-'    
                int 21h            
                     
                mov dl,[si]         ; Print the second group exactly as before     
                int 21h      
                inc si       
                mov dl,[si]    
                int 21h              
                inc si    
                                 
                mov dl, ' '         ; Print a space    
                int 21h    
              
                          
              push cx               ; These registers will be needed, so we save them   
              push si       
              push di
              push bp
              mov bp,sp             ; Copy the stack pointer in the base pointer
              mov ax,[bp+8]         ; Save in ax the first loop counter "i"
              sub cx,ax             ; In cx we currently have the 2nd loop counter "j", so we do the j-i
              mov di,bx      
              mov si,bx    
              add si,cx       
              
              mov ah,1              ; Ask the first team's score, by setting 1 in ah and calling int 21h                        
              int 21h        
              mov cl,al             ; Copy the score in cl
              
              mov ah,2              ; Print a '-'
              mov dl,'-'      
              int 21h            
               
              mov ah,1              ; And then ask for the second score
              int 21h        
              mov ch,al             ; Copy it in ch
                
              mov ah,2              ; Print two spaces just to get things less messy             
              mov dl, ' '    
              int 21h
              int 21h                                 
               
              cmp ch,cl             ; We want to see who has scored more goals, by comparing ch and cl
              jne no_tie            ; If someone has won, go to no_tie
              
              cmp ch,'0'            ; Check if the final result is 0-0
              jne two_points        ; If not go to two_points
              
    mark_1:   add byte ptr [si],1   ; Give 1 point to each team
              add byte ptr [di],1  
              jmp end_score                                        
              
    two_points:               
              add byte ptr [si],2   ; Give 2 points to each team
              mov ax,[si]
              add byte ptr [di],2
              jmp end_score                                        
                           
    no_tie:   cmp ch,cl             ; Check who has won
              jg  home_wins
              add byte ptr [di],3   ; Give 3 points to the winner 
              jmp end_score
                                                      
   home_wins: add byte ptr [si],3   ; Give 3 points to the winner
                  
    
    end_score:                     
              pop bp  
              pop di
              pop si 
              pop cx 
              inc cx
              
          jmp nested_loop  
          end_nested_loop:           
          add di,2            
          pop cx 
          inc cx  
          inc bx     
         jmp outer_loop
                 
     end_matches:   
           call new_line            ; Print a new line
           ret                      ; Return to caller
      get_results endp  
      

      sort proc  near
        
                  
                  mov cx,0            ; Reset cx 
                  inc si              ; Get the address of the first number
           
    
     first_cicle: cmp cx,N            ; Check if we've to loop
                  je end_first_cicle  ; If not, go to f_c1
                  push cx             ; Save the index "i"
                  inc cx              ; Increment it
                  
                  mov di,si           ; Copy the number address in di
                  add di,2            ; And increment it by two to get the other number
                  
    second_cicle: cmp cx,N            ; Compare once more if we've to loop
                  je end_second_cicle ; If not, go to f_c2
                  
                  push cx             ; Save the index "j"
                  push di             ; Save di,si,bp
                  push si
                  push bp
                  mov bp,sp           ; Copy the stack pointer in the base pointer
                  mov di,bx           ; Point vector's base address copied in di
                  mov si,bx           ; And in si as well
                  add di,cx           ; Add an offset to di (cx is the offset)
                  mov cx,[bp+8]       ; Take index "i" and put it in cx
                  add si,cx           ; cx+si gives the position of element "i" 
                  mov al,[si]         ; Copy the number of points in al
                  
                  cmp al,[di]         ; Check if the number of points of the group represented by al is greater than the one of di
                  jg no_swap          ; If the first has a higher score, don't swap
                  
                  cmp al,[di]         ; If they are equal instead
                  je check_name       ; We've to check the subscription (the lower one wins)
                  jmp change          ; If we're here, it means we've to swap
    
    check_name:   
                  pop bp
                  pop si              ; Get the first name
                  pop di              ; Get the second name
                  pop cx              ; Get the index "j"                  
                  mov al,[si]         ; Move in al the first name
                  cmp al,[di]         ; If the first name is greater than the second, swap names
                  jg  swap_name  
                  jmp end_swap
                  
         change:  xchg al,[di]        ; Swap points
                  xchg al,[si]
                  pop bp
                  pop si              ; Get names
                  pop di
                  pop cx   
     swap_name:   mov al,[si]         ; Swap names
                  xchg al,[di]
                  xchg al,[si] 
                  jmp  end_swap
         no_swap:         
                  pop bp
                  pop si
                  pop di
                  pop cx              ; Get index "j"
           end_swap:       
                  inc cx              ; And increase it
                  add di,2
                  
                  jmp second_cicle 
                  
           end_second_cicle:  
                  pop cx       ; Get back index  "i"
                  inc cx
                  add si,2         
                  
                  jmp first_cicle
                  
         end_first_cicle:
                
                     
                      
                  ret
   sort  endp 
   
   ; Procedure to print the ranking    
   print_ranking proc 
          
          mov cx,N              ; Copy in cx the number of teams
          mov ah,2              ; To print to the screen
    
    ranking_loop:                  
             
              mov dl,[si]       ; si has the teams' names
              int 21h           ; Print a team's letter (i.e. if we've A1 print A)
              inc si            ; Move to the subsequent number (1 of A1)
              mov dl,[si]       ; Copy it in dl 
              int 21h           ; And print it
              inc si            ; To the next team
              
              mov dl, ' '       ; Print three spaces
              int 21h
              int 21h        
              int 21h 
                   
              mov dl,[di]       ; Get team's points
              add dl,48         ; Convert them in ASCII
              int 21h           ; Print them
              inc di            ; To the next team's points
              call new_line                 
             
    loop ranking_loop   
               
               ret
        
     print_ranking endp   
        
       ; A procedure to print a new line 
       new_line proc near          
              
               push ax    ; Save ax and dx
               push dx
        
               mov dx,13  ; These two prints
               mov ah,2   ; are necessary in order
               int 21h    ; to print a new line
               mov dx,10
               int 21h 
               
               pop dx     ; Restore ax and dx
               pop ax       
              
              ret 
       new_line endp

end 
