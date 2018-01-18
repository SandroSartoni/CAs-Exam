	.data

.balign 4
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



	.text

	.globl printf
	.globl scanf

/* Function to handle each group's matches */
insert_results:
stp x3,x5,[sp,-16]!
stp x6,x30,[sp,-16]!
stp x0,x4,[sp,-16]!

/* First vs second  */
stp x0,x4,[sp,-16]!

ldr x0,=firstrnd
bl printf

ldp x0,x4,[sp],16

/* Print first team */
ldrb w1,[x0]

bl print_match

/* Get first number of goals */
str x4,[sp,-16]!

ldr x0,=scanpattern
ldr x1,=res1
bl scanf

ldr x4,[sp],16

/* Print second team */
ldr x0,[sp]
ldrb w1,[x0,0x1]

bl print_match

/* Get second number of goals */
str x4,[sp,-16]!

ldr x0,=scanpattern
ldr x1,=res2
bl scanf 

ldr x4,[sp],16

/* Assign points (load number of goals in w0 and w1 and the teams' ranking
 * entries in w2 and w3 */
ldr x0,=res1
ldrb w0,[x0]
ldr x1,=res2
ldrb w1,[x1]

eor x5,x5,x5
mov x6,0x1
ldrb w2,[x4,x5]
ldrb w3,[x4,x6]

bl assign_points

/* Second vs third  */
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

/* Print the group's rank */
ldp x0,x4,[sp],16
bl print_rank 

ldp x6,x30,[sp],16
ldp x3,x5,[sp],16
ret

/* Function to print teams */
print_match:
stp x4,x30,[sp,-16]!

/* r1 stores the team's name, in order to print it:  r1=word, r2=number  */
and w2,w1,0xF
lsr w1,w1,0x4

/* Convert in ascii */
add w1,w1,0x37
add w2,w2,0x30
ldr x0,=str
bl printf

ldp x4,x30,[sp],16
ret

/* Function to assign points */
assign_points:
str x30,[sp,-16]!

/* Check which group has scored the highest number of goals*/
cmp w0,w1

/* If the first team has scored less goals than the second, jump to lessgoals
 * if instead they've scored the same amount of goals, go to equgoals */
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

cbz w0,nogoal

add w2,w2,0x2
add w3,w3,0x2
b moveon

nogoal:

add w2,w2,0x1
add w3,w3,0x1

/* Save in memory the points */
moveon:

strb w2,[x4,x5]
strb w3,[x4,x6]

ldr x30,[sp],16
ret

/* Function to reorder and print rank */
print_rank:
stp x8,x30,[sp,-16]!

/* Reorder rank: load each team and each team's points, w5:first team, w1:first
 * team's points and so on */
ldrb w1,[x4]
ldrb w2,[x4,0x1]
ldrb w3,[x4,0x2]
ldrb w5,[x0]
ldrb w6,[x0,0x1]
ldrb w7,[x0,0x2]

/* Compare first team's points with the second one: if the first has less points
 * then swap the two (both in the ranking and in the point's ranking) */
cmp w1,w2
bge scndcmp
mov w8,w5
mov w5,w6
mov w6,w8
mov w8,w1
mov w1,w2
mov w2,w8

/* Compare first team's points with the third one: if the first has less
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

/* Finally, check also second and third team, and the subscription as well
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

mov w5,#0x3

loop:

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
 * number of goals */
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
 * IS ALLOWED), then store the winner in memory */
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

/* Play the final */
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
	.globl main

main:

	str x30,[sp,-16]!
	
	/* Begin group A matches */	

	ldr x0,=msg1
	bl printf

	/* r0 will be the pointer to the group base address, 
	 * r4 the one to the points array */
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

	/* Check who's the fourth */
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

	/* Play semifinals */
	ldr x0,=semi1msg
	ldr x3,=semi1
	ldr x1,=group1
	ldrb w1,[x1]
	ldr x2,=group2
	ldrb w2,[x2]

	bl semifinals

	ldr x0,=semi2msg
	ldr x3,=semi2
	ldr x1,=group3
	ldrb w1,[x1]
	ldr x2,=fourth
	ldrb w2,[x2]

	bl semifinals

	/* Play final */
	ldr x0,=finmsg
	ldr x1,=semi1
	ldrb w1,[x1]
	ldr x2,=semi2
	ldrb w2,[x2]

	bl final

	ldr x30,[sp],16
	ret
