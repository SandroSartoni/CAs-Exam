/* Solution provided by Sandro Sartoni 

Note: there're some differencies between the 64-bits ARM assembly and the 32-bits one. The most immediate regards
the registers: while in 32-bits mode we've 16 registers, r0-r15, each one on 32 bits, here we've 31 registers
x0-x30 plus, in some instructions, we can refer to one more register called SP (stack pointer), each one on 64-bits.
It's possible, eventually, to refer only to the lowest 32-bits, by changing the 'x' with 'w', i.e. w0 instead of x0.
Other differencies will be discussed in the code.

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
			        is acceptable. POINTS  22
•	Item 2: in addition to Item 1, write a running program implementing the TIE BREAKER RULE #2 inside each group to determine
		    each group standings; POINTS  +3
•	Item 3: in addition to Item 2 (and 1), write a running program identifying the best second classified to be admitted to the
		    second round, according to the following criteria: largest number of points, and, in case of a tie between two
		    teams, TIE BREAKER RULE #1. POINTS  +4
•	Item 4: in addition to Item 3 (and 2), write a running program implementing the second and third (i.e. final) rounds, and
		    identifying the winning team of the tournament, POINTS  +4
•	Bonus Item: in addition to Item 1, write a running program identifying ALL the teams (which could also be more than one) which
		        have score the largest number of goals at the end of first round. POINTS  +4 (identifying only one of the many
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
After having installed pi64 OS, it's quite easy to get this file running by typing:

as -g -o football64.o football64.s
gcc -o football64 football64.o

in the terminal to get the executable, and then to run it: ./football64
These commands will work only if executed when inside the same directory of the source files.
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
winmsg: .asciz "The winner is team %c%c\n"rankmsg: .asciz "Rank:\n"
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


/* .globl printf/scanf are used in order to use printf and scanf in the assembly code. printf takes as arguments x0, that
 * should store the content that has to be printed, and eventually x1-x7 as other arguments if needed, i.e. to print
 * "Hello World!" is sufficient to load on x0 the address of the string and nothing more, while to execute printf("The result
 * of the sum is: %d",var); x0 has to store the address of the string, x1 has to store the address of var.
 * scanf("%d",&var); instead needs to have on x0 the format of the data that we're going to insert, while x1 has to have the
 * address of the memory variable in which we want to store the data. */

	.globl printf
	.globl scanf

/* Function to handle each group's matches */
insert_results:

/* The very first thing done here is to push in the stack all the variables that we don't want to modify in the
 * procedure. In this way, even if we overwrite these registers, by popping them at the end, nothing will change.
 * In 32-bits mode, an easy way to achieve this was to use the multiple store (and multiple load) to push and pop
 * many registers at a time. Here, unfortunately, this is not possible, and the fastest way is to use the stp 
 * function to store a pair of registers. The syntax to store variables in the stack is stp xa,xb,[sp,-16]! : 
 * the 64-bits assembly doesn't need the # before an immediate field, and the stack pointer has to be aligned
 * on a 16 bytes boundary; the meaning of this instruction is: make space for 16 bytes and then store in this
 * space the two registers. It's important to notice that, even when we store one register, we stil have to
 * decrement the sp by 16; the only difference is that when storing one register we can use the store (str) instruction. 
 * The stack grows in a descending way (the stack grows and the address decrements). */

stp x3,x5,[sp,-16]!
stp x6,x30,[sp,-16]!
stp x0,x4,[sp,-16]!

/* First vs second  */
stp x0,x4,[sp,-16]!


/* ldr x0,=firstrnd loads the address of the memory variable named firstrnd, bl printf calls the printf function and
 * at the end it returns to the next instruction after the one that called the function. 
 * ldp loads a pair of variables from the memory, in this case it pops two registers from the stack, updating 
 * the stack pointer after the pop. In this case push and pop are needed in order to preserve the content of 
 * x0 and x4 that are modified by printf. This function modifies other registers too, but they don't store anything
 * interesting, so preserving them is pointless. */

ldr x0,=firstrnd
bl printf

ldp x0,x4,[sp],16

/* Print first team */
/* ldrb w1,[x0] loads a byte from memory at the address provided by the content of x0. This instruction can
 * work only if we specify a 32-bits register as target. */
ldrb w1,[x0]

/* print_match is a procedure implemented inside this program */

bl print_match

/* Get first number of goals */
str x4,[sp,-16]!

ldr x0,=scanpattern
ldr x1,=res1
bl scanf

ldr x4,[sp],16

/* Print second team */
/* load in x0 the content at the TOS, without removing it, load in x1 a byte that's stored at x0 address + 1 byte offset */
ldr x0,[sp]
ldrb w1,[x0,0x1]

bl print_match

/* Get second number of goals */
str x4,[sp,-16]!

ldr x0,=scanpattern
ldr x1,=res2
bl scanf 

ldr x4,[sp],16

/* Assign points (load number of goals in x0 and x1 and the teams' ranking
 * entries in x2 and x3), in particular by loading the address of result, and then loading in the same
 * register the content of said variable. */
 
ldr x0,=res1
ldrb w0,[x0]
ldr x1,=res2
ldrb w1,[x1]

/* eor performs the xor, in particular xoring x5 with x5 itself resets that register. mov x6,#0x1 copies
 * 1 inside x6. ldrb w2,[x4,x5] loads a byte from memory at the address provided by the content of x4, the
 * base address, and x5, the offset.*/

eor x5,x5,x5
mov x6,0x1
ldrb w2,[x4,x5]
ldrb w3,[x4,x6]

/* assign_points is a function implemented in this file */

bl assign_points

/* Second vs third  */
/* The following code performs exactly the same task of the previous one, that is pick two teams of the same group 
 * and ask the user for the final result. It has the same implementation, so the things that were told before apply
 * here as well */
 
str x4,[sp,-16]!

ldr x0,=scndrnd
bl printf

ldr x4,[sp],16

/* Print second team */
ldr x0,[sp]
ldrb w1,[x0,0x1]

bl print_match

/* Get second number of goals */
str x4,[sp,-16]!

ldr x0,=scanpattern
ldr x1,=res1
bl scanf

ldr x4,[sp],16

/* Print third team */
ldr x0,[sp]
ldrb w1,[x0,0x2]

bl print_match

/* Get third number of goals */
str x4,[sp,-16]!

ldr x0,=scanpattern
ldr x1,=res2
bl scanf

ldr x4,[sp],16

/* Assign points (same as before) */
ldr x0,=res1
ldrb w0,[x0]
ldr x1,=res2
ldrb w1,[x1]

mov x5,0x1
mov x6,0x2
ldrb w2,[x4,x5]
ldrb w3,[x4,x6]

bl assign_points

/* First vs third  */
str x4,[sp,-16]!

ldr x0,=thrdrnd
bl printf

ldr x4,[sp],16

/* Print first team */
ldr x0,[sp]
ldrb w1,[x0]

bl print_match

/* Get first number of goals */
str x4,[sp,-16]!

ldr x0,=scanpattern
ldr x1,=res1
bl scanf

ldr x4,[sp],16

/* Print third team */
ldr x0,[sp]
ldrb w1,[x0,0x2]

bl print_match

/* Get third number of goals */
str x4,[sp,-16]!

ldr x0,=scanpattern
ldr x1,=res2
bl scanf

ldr x4,[sp],16

/* Assign points (as before) */
ldr x0,=res1
ldrb w0,[x0]
ldr x1,=res2
ldrb w1,[x1]

eor x5,x5,x5
mov x6,0x2
ldrb w2,[x4,x5]
ldrb w3,[x4,x6]

bl assign_points

/* Print the group's rank, print_rank is a procedure defined in this file. */
ldp x0,x4,[sp],16
bl print_rank 

/* At the end of the procedure, we pop out of the stack the register we pushed in the first place,
 * and then we return with the instruction "ret" */
 
ldp x6,x30,[sp],16
ldp x3,x5,[sp],16
ret

/* Function to print teams */
print_match:
stp x4,x30,[sp,-16]!

/* w1 stores the team's name, in order to print it: w1=word, w2=number. To do that, first we store in w2 the lower
 * w1 four bits by doing an and (and r2,r1,#0xF == r2 <- r1 & 00001111), then we've to modify r1's content in order
 * to make it have only the letter, and we do that by shifting to the right, by four positions, w1. Luckily, here
 * we have a function to simply shift right (or left if needed) the register's content. */
 
and w2,w1,0xF
lsr w1,w1,0x4

/* Convert in ascii: since the output format is a character, we want to convert these values in their relative ascii version
 * In particular: we add 0x37 to w1 to convert it to a letter (A, B or C), and 0x30 to w2 to convert it in a number (1, 2 or 3)*/
 
add w1,w1,0x37
add w2,w2,0x30
ldr x0,=str
bl printf

ldp x4,x30,[sp],16
ret

/* Function to assign points: x2 will store first team's points, x3 instead second team's points. The rules are
 * if a team wins => 3 points, if it looses => 0 points, tie with no goals => 1 point each, ties with goals => 2 points each. */
 
assign_points:
str x30,[sp,-16]!

/* Check which group has scored the highest number of goals.
 * cmp subtracts from the first register the second one, it doesn't store the result anywhere but it updates
 * the processor's flags. */
 
cmp w0,w1

/* If the first team has scored less goals than the second, jump to lessgoals
 * if instead they've scored the same amount of goals, go to equgoals.
 * To do that, we append to the instruction b label (unconditional jump)
 * a suffix, mi or eq in this case, that means that if, checking the processor's flags
 * we find that r0 is less than r1, we've to jump to less goals, instead if the two
 * are equal, jump to equgoals. The branch syntax is the following: 
 * b label jumps directly to the code section in which we have label:
 * In 32-bits assembly most instructions have the possibility to append the suffix, that
 * is to be conditionally executed, in the 64-bits version only few instructions can still
 * be conditonally executed, one of these is the branch instruction. */

bmi lessgoals
beq equgoals

/* If we're here, it means that the first team has won */
add w2,w2,0x3
b moveon

/* If we're here, it means that the second team has won */
lessgoals:

add w3,w3,0x3
b moveon

/* If we're here, it means the game ended with a tie, but we've to see if 
 * at least one goal has been scored, if not go to nogoals */
equgoals:

/* This instruction is "compare and branch if 0", in this way we can do the comparison and the branch
 * in one instruction. */ 
cbz w0,nogoal

add w2,w2,0x2
add w3,w3,0x2
b moveon

nogoal:

add w2,w2,0x1
add w3,w3,0x1

/* Save in memory the points */
moveon:

/* Store points of both teams in memory, as bytes */
strb w2,[x4,x5]
strb w3,[x4,x6]

ldr x30,[sp],16
ret

/* Function to reorder and print rank */
print_rank:
stp x8,x30,[sp,-16]!

/* Reorder rank: load each team and each team's points, w5:first team, w1:first
 * team's points and so on. x4 stores the point array's base address, x0 the group array's base address. */
 
ldrb w1,[x4]
ldrb w2,[x4,0x1]
ldrb w3,[x4,0x2]
ldrb w5,[x0]
ldrb w6,[x0,0x1]
ldrb w7,[x0,0x2]

/* Compare first team's points (w1) with the second one (w2): if the first has less points then swap the two (both in the ranking and in
 * the point's ranking). In order to do that, we use mov with a temporary register (w8) to do the swap (mov xa,xb => xa <- xb) */

cmp w1,w2
bge scndcmp
mov w8,w5
mov w5,w6
mov w6,w8
mov w8,w1
mov w1,w2
mov w2,w8

/* Compare first team's points (w1) with the third one (w3): if the first has less
 * points, then swap the two (as before) */
scndcmp:

cmp w1,w3
bge chkeq2
mov w8,w5
mov w5,w7
mov w7,w8
mov w8,w1
mov w1,w3
mov w3,w8
b thrdcmp

/* Not only this, we also want to make sure that the team with the lowest 
 * subscription has a higher position (if points are equal) */
chkeq2:

cmp w5,w7
bmi thrdcmp
mov w8,w5
mov w5,w7
mov w7,w5

/* Finally, check also second (w2) and third team (w3), and the subscription as well
 * as before */
thrdcmp:

cmp w2,w3
bge chckeq3
mov w8,w6
mov w6,w7
mov w7,w8
mov w8,w2
mov w2,w3
mov w3,w8
b fnshd

chckeq3:

cmp w6,w7
bmi fnshd
mov w8,w6
mov w6,w7
mov w7,w8

/* When everything is sorted as it should be, we can store everything
 * in memory */
fnshd:
strb w1,[x4]
strb w2,[x4,0x1]
strb w3,[x4,0x2]
strb w5,[x0]
strb w6,[x0,0x1]
strb w7,[x0,0x2]

/* Print rank: loop until every entry has been printed, along its correspondent
 * team  */
stp x0,x4,[sp,-16]!

ldr x0,=rankmsg
bl printf

ldp x0,x4,[sp],16

/* Copy in w5 the number of iterations */
mov w5,#0x3

loop:

/* To print the ranking, load in w1 the team and in w3 its points, post incrementing x0 and x4 by one (first load
 * then increment the pointer), then arrange w1 and w2 to print the team's name as before (w1=letter, w2=number)
 * convert them in ascii mode by adding 0x37 to w1 and 0x30 to w2, keep in w3 the points and finally print everything. */

ldrb w1,[x0],0x1
ldrb w3,[x4],0x1
and w2,w1,0xF
lsr w1,w1,0x4

stp x0,x4,[sp,-16]!
str x5,[sp,-16]!

ldr x0,=strpoint
add w1,w1,0x37
add w2,w2,0x30
bl printf

ldr x5,[sp],16
ldp x0,x4,[sp],16

/* Decrement w5 and if not zero, branch => cbnz == compare and branch if not zero (compare w5) */
sub w5,w5,0x1
cbnz w5,loop

ldp x8,x30,[sp],16
ret

/* Function to find the fourth classified */
find_fourth:
str x30,[sp,-16]!

/* Start by loading the second classified in group A inside w3 */
mov w3,w4

/* Compare second classified in group A's points with second classified in
 * group C's points, if minor, save the latter in w3 */
cmp w0,w1
bge cmpsecthr
mov w3,w5

/* Compare second classified in group B's points with second classified in
 * group C's points, the one who has more points goes into w3 */
cmpsecthr:

cmp w1,w2
bge movw3w5
mov w3,w6
b cmpfrsthr

movw3w5:

mov w3,w5

/* Same as before */
cmpfrsthr:

cmp w0,w2
bge movw3w4
mov w3,w6
b strw3

movw3w4:

mov w3,w4

/* Finally, store in memory the fourth classified */
strw3:

ldr x4,=fourth
strb w3,[x4]

ldr x30,[sp],16
ret

/* Semifinals function  */
semifinals:
str x30,[sp,-16]!

/* Print the semifinal message and ask the user for the first team's
 * number of goals. The string has been loaded in r0 in the main, while r1 and r2
 * store the teams that will play the match. At first, print and ask for the first team's
 * number of goals. */
 
stp x0,x1,[sp,-16]!
stp x2,x3,[sp,-16]!

bl printf

ldp x2,x3,[sp],16
ldp x0,x1,[sp],16

stp x0,x1,[sp,-16]!
stp x2,x3,[sp,-16]!

bl print_match

ldr x0,=scanpattern
ldr x1,=res1
bl scanf

ldp x2,x3,[sp],16
ldp x0,x1,[sp],16

/* And then ask for the second team's number of goals */
str x1,[sp,-16]!

mov w1,w2

stp x0,x1,[sp,-16]!
stp x2,x3,[sp,-16]!

bl print_match

ldr x0,=scanpattern
ldr x1,=res2
bl scanf

ldp x2,x3,[sp],16
ldp x0,x1,[sp],16

ldr x1,[sp],16

/* In order to determine who wins, check the number of goals per team (NO TIE
 * IS ALLOWED), then store the winner in memory. The memory address is inside
 * x3. */
ldr x4,=res1
ldrb w4,[x4]
ldr x5,=res2
ldrb w5,[x5]

cmp w4,w5
bmi win2
strb w1,[x3]
b end

win2:
strb w2,[x3]

end:

ldr x30,[sp],16
ret

/* Play the final. The function is quite similar to the semifinals one, the only difference is that here we
 * don't have to save anything into memory, on the contrary the only thing to do is to print the winner. */
final:
str x30,[sp,-16]!

/* Print the final string, then ask the user for the first team's number
 * of goals */
stp x0,x1,[sp,-16]!
str x2,[sp,-16]!

bl printf

ldr x2,[sp],16
ldp x0,x1,[sp],16

stp x0,x1,[sp,-16]!
str x2,[sp,-16]!

bl print_match

ldr x0,=scanpattern
ldr x1,=res1
bl scanf

ldr x2,[sp],16
ldp x0,x1,[sp],16

/* Same thing for the second team */
str x1,[sp,-16]!
mov w1,w2

stp x0,x1,[sp,-16]!
str x2,[sp,-16]!

bl print_match

ldr x0,=scanpattern
ldr x1,=res2
bl scanf

ldr x2,[sp],16
ldp x0,x1,[sp],16

/* Finally, determine who's the winner and print it */
ldr x1,[sp],16

ldr x4,=res1
ldrb w4,[x4]
ldr x5,=res2
ldrb w5,[x5]

cmp w4,w5
bge printwinner
mov w1,w2

/* Section to print the winner */
printwinner:

and w2,w1,0xF
lsr w1,w1,0x4

add w1,w1,0x37
add w2,w2,0x30

ldr x0,=winmsg
bl printf

ldr x30,[sp],16
ret

/* Here is where the main begins, the assembler will start the execution from here. */

	.globl main

main:

/* The first thing to do is to store the link register in order to come back once the program has termined. Then, we
 * can move on to the matches regarding the first group, following with the second and finally the third group.
 * Next, it's necessary to find the fourth classified and then we can play the semifinals and the final. */

	str x30,[sp,-16]!
	
	/* Begin group A matches */	

	ldr x0,=msg1
	bl printf

	/* x0 will be the pointer to the group base address, 
	 * x4 the one to the points array. This is going to be
	 * valid even for group B and C. */
	ldr x0,=group1
	ldr x4,=point1

	bl insert_results

	/* Begin group B matches */
	ldr x0,=msg2
	bl printf
	
	ldr x0,=group2
	ldr x4,=point2
	
	bl insert_results

	/* Begin group C matches */
	ldr x0,=msg3
	bl printf

	ldr x0,=group3
	ldr x4,=point3

	bl insert_results

	/* Check who's the fourth. Before calling the procedure, load each second 
	 * classified team and its points in this way: w0 stores A's second classified
	 * w4 its points, w1 stores B's second classified and w5 its points and w2
	 * stores C's second classified and w6 its points. */
	 
	ldr x0,=point1
	ldr x1,=point2
	ldr x2,=point3
	ldr x4,=group1
	ldr x5,=group2
	ldr x6,=group3
	ldrb w0,[x0,0x1]
	ldrb w1,[x1,0x1]
	ldrb w2,[x2,0x1]
	ldrb w4,[x4,0x1]
	ldrb w5,[x5,0x1]
	ldrb w6,[x6,0x1]
	
	
	bl find_fourth

	/* Play semifinals, after loading in w1 and w2 the A's and B's first classified and
	 * in x3 the memory location in which the winner will be stored */
	ldr x0,=semi1msg
	ldr x3,=semi1
	ldr x1,=group1
	ldrb w1,[x1]
	ldr x2,=group2
	ldrb w2,[x2]

	bl semifinals

	/* As before, play the semifinals, this time loading the C's group first classified in w1
	 * and the fourth classified in w2 */

	ldr x0,=semi2msg
	ldr x3,=semi2
	ldr x1,=group3
	ldrb w1,[x1]
	ldr x2,=fourth
	ldrb w2,[x2]

	bl semifinals

	/* Finally, load the two finalists in w1 and w2 and play the final */
	
	ldr x0,=finmsg
	ldr x1,=semi1
	ldrb w1,[x1]
	ldr x2,=semi2
	ldrb w2,[x2]

	bl final

	/* Pop the link register from the stack and end this program */

	ldr x30,[sp],16
	ret
