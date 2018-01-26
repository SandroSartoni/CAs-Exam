/* Solution provided by Sandro Sartoni 

**********************************************************************************************************************************

Exam's text:

A University soccer tournament accounts 9 teams grouped in 3 sets (A, B, C), each one hosting 3 teams, named A1, A2, A3 for
set A, B1, B2, B3 for set B, and C1, C2, C3 for set C. During the first round, each team same plays two games against the other
two in the set and a victory is awarded 3 points, a draw with goals is awarded 2 points to each team, a draw without goals
is awarded 1 point to each team and a loss 0 points. After the first round the top teams of each set are admitted to the second
round, plus the “best” team of the second classified, i.e. the second classified with more points. These four teams play one
versus the other this way: Winner of set A vs. Winner of set B and Winner of set C vs. the best second classified. The winners
of the two games (no tie is possible) play the final and the winner of the final is the winner of the University championship.

It is requested to write an 8086 assembly program to manage the tournament games and rules, based on the scores that are
received in input by the user. In particular, for each group, the program should present the user with the names of the two
teams and the user has to enter the score (assuming that no team can score more than 9 goals in a single match). The program
should compute and present the standings for each group at the end of the first round, together with the names of the teams
which are admitted to the second round. Then, the program has to present the second round games, receive the results and
identify the two teams, which will play the final. Lastly, the programs should present the two names of these two teams, playing
the final and, based on the result received in input, present the winner of the tournament. For example:

A1-A2 = 0-0; A1-A3 = 0-1; A3-A2 = 1-1; leads to the standings: A3 = 5 points; A2 = 3 points; A1 = 1 point
B1-B2 = 2-0; B1-B3 = 2-1; B3-B2 = 1-1; leads to the standings: B1 = 6 points; B2 = 2 points; B3 = 2 points
C1-C2 = 4-0; C1-C3 = 4-0; C3-C2 = 0-0; leads to the standings: C1 = 6 points; C2 = 1 point; C3 = 1 point

The winners are, A3, B1, and C1, while the second best classified is A2. Therefore, second round games are: A3-B1, and C1-A2.
Assume that A3-B1 = 0-1, and C1-A2 = 3-4, then the final will be B1 versus A2; assuming that B1-A2 = 4-5, then the winner of the
tournament will be team A3.

In the previous example, the identification of the teams admitted to second round is very easy as there have been no ties
in the number of points awarded. It is ensured that no three-teams ties will occur. The rules in case of a two-teams tie are as
follows (TIE BREAKER RULES):
1.	The tie is won by the team with the lowest alphabetical letter;
2.	In case of further tie, the tie is won by the team with the lowest subscript.

For example: with the previous score, for group B, both B2 and B3 have 2 points and so the question is: which is the second
classified in the set? According to rule #2, B2 is the second classified because it has a lower subscript (rule #1 has no
effect here). For group C, both C2 and C3 have 1 point and according rule #2 the second classified is C2.

Please observe that rule #2 can solve a tie inside a group, while rule #1 solves the ties across groups. For example, assuming
that the three second classified are A3=2 points, B2=3 points, C2=3 points, then, out of B2 and C2, rule #1 decides the
tie, in favor of B2.

Tasks to be implemented and corresponding point (only fully completed items will be considered to award points)
•	Item 1 (MANDATORY): write a running program fully implementing the first round ONLY and computing the standings after the
			        first round. In case of two teams with the same number of points inside a group, any ranking of the two
			        is acceptable. POINTS -> 22
•	Item 2: in addition to Item 1, write a running program implementing the TIE BREAKER RULE #2 inside each group to determine
		    each group standings; POINTS -> +3
•	Item 3: in addition to Item 2 (and 1), write a running program identifying the best second classified to be admitted to the
		    second round, according to the following criteria: largest number of points, and, in case of a tie between two
		    teams, TIE BREAKER RULE #1. POINTS -> +4
•	Item 4: in addition to Item 3 (and 2), write a running program implementing the second and third (i.e. final) rounds, and
		    identifying the winning team of the tournament, POINTS -> +4
•	Bonus Item: in addition to Item 1, write a running program identifying ALL the teams (which could also be more than one) which
		        have score the largest number of goals at the end of first round. POINTS -> +4 (identifying only one of the many
		        awards at most 2 extra points).
Please consider that a maximum of 33 points can be accounted here; larger values will be “cut off” to 33.

HINTS (observe that)
•	It is ensured that no three-teams ties will occur 
•	It is advised to design the program as a collection of modules, each one implementing the different Items.

REQUIREMENTS (SHARP)
•	It is not required to provide the optimal (shortest, most efficient, fastest) solution, but a working and clear one. 
•	It is required to write at class time a short and clear explanation of the algorithm used.
•	It is required to write at class time significant comments to the instructions.
•	Input-output is not necessary in class-developed solution, but its implementation is mandatory for the oral exam.
•	Minimum score to “pass” this part is 15 (to be averaged with second part and to yield a value at least 18)

REQUIREMENTS ON THE I/O PART TO BE DONE AT HOME
•	The databases (if any, i.e. not necessary in case) have to be defined and initialized inside the code 
•	All inputs and outputs should be in readable ASCII form (no binary is permitted).

*********************************************************************************************************************************       

How to get this file running on Raspberry Pi 3:
After having installed pi64 OS, it's necessary to enable multiarch, install all the libraries and the compiler:
sudo dpkg --add-architecture armhf
sudo apt-get update
sudo apt-get install libc6:armhf
sudo apt-get install libc6-armel-cross libc6-dev-armel-cross
sudo apt-get install binutils-arm-linux-gnueabi
sudo apt-get install libncurses5-dev
sudo apt-get install gcc-arm-linux-gnueabi
sudo apt-get install g++-arm-linux-gnueabi
To generate the executable file, it's necessary to type arm-linux-gnueabi-gcc filename.s -o filename.
If, by typing ./filename there're still problems, type file ./filename and, if there's written interpreter /lib/ld-linux.so.3 then
it's necessary to write sudo ln -s /lib/ld-linux-armhf.so.3 /lib/ld-linux.so.3. 
*/

/* .data is a directive that allows us to define all the memory variables required in our program */

	.data
	
/* .balign <power_of_two> aligns the address of whatever is below to <power_of_two> bytes. If the address is
 * already a multiple of <power_of_two> bytes, it does nothing. This instruction is required by the processor in order to work
 * correctly, failures to do so may generate errors */
 
.balign 4

/* To create memory variables, the syntax is: <variable_name>: .<type_of_variable> value1[,value2,...]. In the first line
 * for example, we're generating a set of variables, each one that has 1 byte of size, named group1, with values
 * 0xA1, 0xA2 and 0xA3 (hexadecimal). Below, .asciz "<content_of_the_string>" is creating a memory variable that is a
 * string, in ascii format followed by a 0 byte (the 'z' in asciz), initialized with the content inside the quotation
 * marks. */
 
group1: .byte 0xA1,0xA2,0xA3
group2: .byte 0xB1,0xB2,0xB3
group3: .byte 0xC1,0xC2,0xC3
point1: .byte 0,0,0
point2: .byte 0,0,0
point3: .byte 0,0,0

msg1: .asciz "Group A matches\n"
msg2: .asciz "Group B matches\n"
msg3: .asciz "Group C matches\n"
firstrnd: .asciz "First round\n"
scndrnd: .asciz "Second round\n"
thrdrnd: .asciz "Third round\n"
semi1msg: .asciz "First semifinal\n"
semi2msg: .asciz "Second semifinal\n"
finmsg: .asciz "Final\n"
winmsg: .asciz "The winner is team %c%c\n"
rankmsg: .asciz "Rank:\n"
str: .asciz "%c%c: "
strpoint: .asciz "%c%c: %d\n"

scanpattern: .asciz "%d"

fourth: .byte 0
semi1: .byte 0
semi2: .byte 0
res1: .byte 0
res2: .byte 0

/* .text is a directive that tells the assembler where the code starts */

	.text

/* .global printf/scanf are used in order to use printf and scanf in the assembly code. printf takes as arguments r0, that
 * should store the content that has to be printed, and eventually r1, r2, r3 as other arguments if needed, i.e. to print
 * "Hello World!" is sufficient to load on r0 the address of the string and nothing more, while to execute printf("The result
 * of the sum is: %d",var); r0 has to store the address of the string, r1 has to store the address of var.
 * scanf("%d",&var); instead needs to have on r0 the format of the data that we're going to insert, while r1 has to have the
 * address of the memory variable in which we want to store the data. */

	.global printf
	.global scanf

/* Function to handle each group's matches, named insert_results */
insert_results:

/* stmfd is a function that stores multiple registers, in this case it's used to push multiple registers into the stack.
 * In particular, sp! automatically updates the stack pointer (in 32-bit ARM assembly, the stack has to be aligned on a
 * 4 bytes boundary, and it grows descending the memory, that means that every time something is pushed the address is
 * decremented by 4). In the first instruction, we're storing all the registers from r3 to r6 (both included) and the link
 * register, the link register is needed at the end of the procedure in order to return to the correct point in the main
 * function. */
 
stmfd sp!,{r3-r6,lr}
stmfd sp!,{r0}

/* First vs second  */
stmfd sp!,{r0-r3}

/* ldr r0,=firstrnd loads the address of the memory variable named firstrnd, bl printf calls the printf function and
 * at the end it returns to the next instruction after the one that called the function. 
 * ldmfd loads multiple data from the memory, in this case it pops multiple registers from the stack, updating 
 * automatically the stack pointer. In this case push and pop are needed in order to preserve the content of 
 * r0-r3 registers that are modified by printf. */

ldr r0,=firstrnd
bl printf
ldmfd sp!,{r0-r3}

/* Print first team */
/* ldrb r1,[r0] loads a byte from memory at the address provided by the content of r0 */

ldrb r1,[r0]

/* print_match is a procedure implemented inside this program */

bl print_match

/* Get first number of goals */
ldr r0,=scanpattern
ldr r1,=res1
bl scanf

/* Print second team */
/* load in r0 the content at the TOS, without removing it, load in r1 a byte that's stored at r0 address + 1 byte offset */
ldr r0,[sp]
ldrb r1,[r0,#0x1]

bl print_match

/* Get second number of goals */
ldr r0,=scanpattern
ldr r1,=res2
bl scanf 

/* Assign points (load number of goals in r0 and r1 and the teams' ranking
 * entries in r2 and r3), in particular by loading the address of result, and then loading in the same
 * register the content of said variable. */
 
ldr r0,=res1
ldrb r0,[r0]
ldr r1,=res2
ldrb r1,[r1]

/* eor performs the xor, in particular xoring r5 with r5 itself resets that register. mov r6,#0x1 copies
 * 1 inside r6. ldrb r2,[r4,r5] loads a byte from memory at the address provided by the content of r4, the
 * base address, plus r5's content, the offset.*/
 
eor r5,r5
mov r6,#0x1
ldrb r2,[r4,r5]
ldrb r3,[r4,r6]

/* assign_points is a procedure implemented in this file */
bl assign_points

/* Second vs third  */
/* The following code performs exactly the same task of the previous one, that is pick two teams of the same group 
 * and ask the user for the final result. It has the same implementation, so the things that were told before apply
 * here as well */
 
stmfd sp!,{r0-r3}
ldr r0,=scndrnd
bl printf
ldmfd sp!,{r0-r3}

/* Print second team */
ldr r0,[sp]
ldrb r1,[r0,#0x1]

bl print_match

/* Get second number of goals */
ldr r0,=scanpattern
ldr r1,=res1
bl scanf

/* Print third team */
ldr r0,[sp]
ldrb r1,[r0,#0x2]

bl print_match

/* Get third number of goals */
ldr r0,=scanpattern
ldr r1,=res2
bl scanf

/* Assign points (same as before) */
ldr r0,=res1
ldrb r0,[r0]
ldr r1,=res2
ldrb r1,[r1]

mov r5,#0x1
mov r6,#0x2
ldrb r2,[r4,r5]
ldrb r3,[r4,r6]

bl assign_points

/* First vs third  */
stmfd sp!,{r0-r3}
ldr r0,=thrdrnd
bl printf
ldmfd sp!, {r0-r3}

/* Print first team */
ldr r0,[sp]
ldrb r1,[r0]

bl print_match

/* Get first number of goals */
ldr r0,=scanpattern
ldr r1,=res1
bl scanf

/* Print third team */
ldr r0,[sp]
ldrb r1,[r0,#0x2]

bl print_match

/*Get third number of goals */
ldr r0,=scanpattern
ldr r1,=res2
bl scanf

/* Assign points (as before) */
ldr r0,=res1
ldrb r0,[r0]
ldr r1,=res2
ldrb r1,[r1]

eor r5,r5
mov r6,#0x2
ldrb r2,[r4,r5]
ldrb r3,[r4,r6]

bl assign_points

/* Print the group's rank, print_rank is a procedure defined in this file */
ldmfd sp!,{r0}
bl print_rank 

/* At the end of the procedure, we pop out of the stack the register we pushed in the first place,
 * and then we return with the instruction "bx lr" */
 
ldmfd sp!,{r3-r6,lr}
bx lr

/* Function to print teams */
print_match:
stmfd sp!,{r4,lr}

/* r1 stores the team's name, in order to print it: r1=word, r2=number. To do that, first we store in r2 the lower
 * r1 four bits by doing an and (and r2,r1,#0xF == r2 <- r1 & 00001111), then we've to modify r1's content in order
 * to make it have only the letter, and we do that by removing the lower four bits with the and r1,r1,#0xF0, resetting
 * r4 (only temporarily, since the original r4 content was pushed in the stack and it will be popped out of the stack
 * at the end) and doing the addition add r1,r4,r1,lsr #0x4 : since in 32-bit state there's no way to perform a shift
 * operation by itself, the workaround consists in adding 0 to r1 shifted to the right by four positions (in this case)
 * and storing the result in r1. */
 
and r2,r1,#0xF
and r1,r1,#0xF0
eor r4,r4
add r1,r4,r1,lsr #0x4

/* Convert in ascii: since the output format is a character, we want to convert these values in their relative ascii version
 * In particular: we add 0x37 to r1 to convert it to a letter (A, B or C), and 0x30 to r2 to convert it in a number (1, 2 or 3)*/
 
add r1,r1,#0x37
add r2,r2,#0x30
ldr r0,=str
bl printf

ldmfd sp!,{r4,lr}
bx lr

/* Function to assign points: r2 will store first team's points, r3 instead second team's points. The rules are
 * if a team wins => 3 points, if it looses => 0 points, tie with no goals => 1 point each, ties with goals => 2 points each. */
 
assign_points:
stmfd sp!,{r0-r3,lr}

/* Check which group has scored the highest number of goals.
 * cmp subtracts from the first register the second one, it doesn't store the result anywhere but it updates
 * the processor's flags. */
 
cmp r0,r1

/* If the first team has scored less goals than the second, jump to lessgoals
 * if instead they've scored the same amount of goals, go to equgoals.
 * To do that, we append to the instruction b label (unconditional jump)
 * a suffix, mi or eq in this case, that means that if, checking the processor's flags
 * we find that r0 is less than r1, we've to jump to less goals, instead if the two
 * are equal, jump to equgoals. The branch syntax is the following: 
 * b label jumps directly to the code section in which we have label:*/
 
bmi lessgoals
beq equgoals

/* If we're here, it means that the first team has won */
add r2,r2,#0x3
b moveon

/* If we're here, it means that the second team has won */
lessgoals:

add r3,r3,#0x3
b moveon

/* If we're here, it means the game ended with a tie, but we've to see if
 * at least one goal has been scored, if not go to nogoals */
equgoals:

cmp r0,#0
beq nogoal

add r2,r2,#0x2
add r3,r3,#0x2
b moveon

nogoal:

add r2,r2,#0x1
add r3,r3,#0x1

/* Save in memory the points  */
moveon:

/* Store points of both teams in memory, as bytes. */
strb r2,[r4,r5]
strb r3,[r4,r6]

ldmfd sp!,{r0-r3,lr}
bx lr

/* Function to reorder and print rank */
print_rank:
stmfd sp!,{r5-r8,lr}

/* Reorder rank: load each team and each team's points, r5:first team, r1:first
 * team's points, and so on. r4 stores the point array's base address, r0 the group array's base address. */
 
ldrb r1,[r4]
ldrb r2,[r4,#0x1]
ldrb r3,[r4,#0x2]
ldrb r5,[r0]
ldrb r6,[r0,#0x1]
ldrb r7,[r0,#0x2]

/* Compare first team's points (r1) with the second one (r2): if the first has less points then swap the two (both in the ranking and in
 * the point's ranking). In order to do that, we use mov with a temporary register (r8) to do the swap (mov rx,ry => rx <- ry) */
cmp r1,r2
bge scndcmp
mov r8,r5
mov r5,r6
mov r6,r8
mov r8,r1
mov r1,r2
mov r2,r8

/* Compare first team's points (r1) with the third one (r3): if the first has less
 * points, then swap the two (as before)  */
scndcmp:

cmp r1,r3
bge chkeq2
mov r8,r5
mov r5,r7
mov r7,r8
mov r8,r1
mov r1,r3
mov r3,r8
b thrdcmp

/* Not only this, we also want to make sure that the team with the lowest
 * subscription has a higher position (if points are equal)  */
chkeq2:

cmp r5,r7
bmi thrdcmp
mov r8,r5
mov r5,r7
mov r7,r5

/* Finally, check also second (r2) and third team (r3) and the subscription as well
 * as before  */
thrdcmp:

cmp r2,r3
bge chckeq3
mov r8,r6
mov r6,r7
mov r7,r8
mov r8,r2
mov r2,r3
mov r3,r8
b fnshd

chckeq3:

cmp r6,r7
bmi fnshd
mov r8,r6
mov r6,r7
mov r7,r8

/* When everything is sorted as it should be, we can store everything
 * in the memory  */
fnshd:
strb r1,[r4]
strb r2,[r4,#0x1]
strb r3,[r4,#0x2]
strb r5,[r0]
strb r6,[r0,#0x1]
strb r7,[r0,#0x2]

/* Print rank: loop until every entry has been printed, along its correspondent
 * team  */
stmfd sp!,{r0-r3}
ldr r0,=rankmsg
bl printf
ldmfd sp!,{r0-r3}

/* Store in r5 the number of iterations */
mov r5,#0x3
eor r6,r6

loop:

/* To print the ranking, load in r1 the team and in r3 its points, post incrementing r0 and r4 by one (first load
 * then increment the pointer), then arrange r1 and r2 to print the team's name as before (r1=letter, r2=number)
 * convert them in ascii mode by adding 0x37 to r1 and 0x30 to r2, keep in r3 the points and finally print everything. */

ldrb r1,[r0],#0x1
ldrb r3,[r4],#0x1
and r2,r1,#0xF
add r1,r6,r1,lsr #0x4

stmfd sp!,{r0-r3}
ldr r0,=strpoint
add r1,r1,#0x37
add r2,r2,#0x30
bl printf
ldmfd sp!,{r0-r3}

sub r5,r5,#0x1
cmp r6,r5
bmi loop

ldmfd sp!,{r5-r8,lr}
bx lr

/* Function to find the fourth classified */
find_fourth:
stmfd sp!,{r4-r6,lr}

/* Load in r4, r5 and r6 the second classified for each team */
ldr r4,=group1
ldrb r4,[r4,#0x1]
ldr r5,=group2
ldrb r5,[r5,#0x1]
ldr r6,=group3
ldrb r6,[r6,#0x1]

/* Start by loading the second classified in group A inside r3  */
mov r3,r4

/* Compare second classified in group A's points with second classified in
 * group C's points, if minor, save the latter in r3. Notice that movmi and later movge
 * are just the mov instruction executed if r0 is less than r1 (if ge it means if it's greater
 * or equal). */ 
cmp r0,r1
movmi r3,r5

/* Compare second classified in group B's points with second classified in
 * group C's points, the one who has more points goes into r3 */ 
cmp r1,r2
movmi r3,r6
movge r3,r5

/* Same as before */
cmp r0,r2
movmi r3,r6
movge r3,r4

/* Finally, store in memory the fourth classified */
ldr r4,=fourth
strb r3,[r4]

ldmfd sp!,{r4-r6,lr}
bx lr

/* Semifinals function  */
semifinals:
stmfd sp!,{r4,r5,lr}

/* Print the semifinal message and ask the user for the first team's
 * number of goals. The string has been loaded in r0 in the main, while r1 and r2
 * store the teams that will play the match. At first, print and ask for the first team's
 * number of goals. */
 
stmfd sp!,{r0-r3}
bl printf
ldmfd sp!,{r0-r3}

stmfd sp!,{r0-r3}
bl print_match

ldr r0,=scanpattern
ldr r1,=res1
bl scanf

ldmfd sp!,{r0-r3}

/* And then ask for the second team's number of goals. */
stmfd sp!,{r1}
mov r1,r2

stmfd sp!,{r0-r3}
bl print_match

ldr r0,=scanpattern
ldr r1,=res2
bl scanf

ldmfd sp!,{r0-r3}

ldmfd sp!,{r1}

/* In order to determine who wins, check the number of goals per team (NO TIE
 * IS ALLOWED), then store the winner in memory. The memory address is inside
 * r3. */
 
ldr r4,=res1
ldrb r4,[r4]
ldr r5,=res2
ldrb r5,[r5]

cmp r4,r5
bmi win2
strb r1,[r3]
b end

win2:
strb r2,[r3]

end:

ldmfd sp!,{r4,r5,lr}
bx lr

/* Play the final. The function is quite similar to the semifinals one, the only difference is that here we
 * don't have to save anything into memory, on the contrary the only thing to do is to print the winner. */
final:
stmfd sp!,{r4,r5,lr}

/* Print the final string, then ask the user for the first team's number
 * of goals */
stmfd sp!,{r0-r3}
bl printf
ldmfd sp!,{r0-r3}

stmfd sp!,{r0-r3}
bl print_match

ldr r0,=scanpattern
ldr r1,=res1
bl scanf

ldmfd sp!,{r0-r3}

/* Same thing for the second team */
stmfd sp!,{r1}
mov r1,r2

stmfd sp!,{r0-r3}
bl print_match

ldr r0,=scanpattern
ldr r1,=res2
bl scanf

ldmfd sp!,{r0-r3}

/* Finally, determine who's the winner and print it */
ldmfd sp!,{r1}

ldr r4,=res1
ldrb r4,[r4]
ldr r5,=res2
ldrb r5,[r5]

cmp r4,r5
movmi r1,r2

/* Section to print the winner */
and r2,r1,#0xF
eor r4,r4
add r1,r4,r1, lsr #0x4

add r1,r1,#0x37
add r2,r2,#0x30

stmfd sp!,{r0-r3}
ldr r0,=winmsg
bl printf
ldmfd sp!,{r0-r3}

ldmfd sp!,{r4,r5,lr}
bx lr

/* Here is where the main begins, the execution starts from here. */

	.global main

main:

/* The first thing to do is to store the link register in order to come back once the program has termined. Then, we
 * can move on to the matches regarding the first group, following with the second and finally the third group.
 * Next, it's necessary to find the fourth classified and then we can play the semifinals and the final. */

	stmfd sp!,{lr}
	
	/* Begin group A matches */
	stmfd sp!,{r0-r3}
	ldr r0,=msg1
	bl printf
	ldmfd sp!,{r0-r3}

	/* r0 will be the pointer to the group base address, 
	 * r4 the one to the points array. This will be valid
	 * even for group B and C matches. */
	ldr r0,=group1
	ldr r4,=point1

	bl insert_results

	/* Begin group B matches */
	stmfd sp!,{r0-r3}
	ldr r0,=msg2
	bl printf
	ldmfd sp!,{r0-r3}
	
	ldr r0,=group2
	ldr r4,=point2
	
	bl insert_results

	/* Begin group C matches */
	stmfd sp!,{r0-r3}
	ldr r0,=msg3
	bl printf
	ldmfd sp!,{r0-r3}

	ldr r0,=group3
	ldr r4,=point3

	bl insert_results

	/* Check who's the fourth. Before calling the procedure, load each
	 * second classified team's points. */
	ldr r0,=point1
	ldr r1,=point2
	ldr r2,=point3
	ldrb r0,[r0,#0x1]
	ldrb r1,[r1,#0x1]
	ldrb r2,[r2,#0x1]
	
	bl find_fourth

	/* Play semifinals, after loading in r1 and r2 the A's and B's first classified and
	 * in r3 the memory location in which the winner will be stored */
	ldr r0,=semi1msg
	ldr r3,=semi1
	ldr r1,=group1
	ldrb r1,[r1]
	ldr r2,=group2
	ldrb r2,[r2]

	bl semifinals
	
	/* As before, play the semifinals, this time loading the C's group first classified in r1
	 * and the fourth classified in r2 */
	ldr r0,=semi2msg
	ldr r3,=semi2
	ldr r1,=group3
	ldrb r1,[r1]
	ldr r2,=fourth
	ldrb r2,[r2]

	bl semifinals

	/* Finally, load the two finalists in r1 and r2 and play the final */
	ldr r0,=finmsg
	ldr r1,=semi1
	ldrb r1,[r1]
	ldr r2,=semi2
	ldrb r2,[r2]

	bl final

	/* Pop the link register from the stack and end this program */
	ldmfd sp!,{lr}
	bx lr
