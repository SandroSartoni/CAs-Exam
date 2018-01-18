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

	.global printf
	.global scanf

/* Function to handle each group's matches */
insert_results:
stmfd sp!,{r3-r6,lr}
stmfd sp!,{r0}

/* First vs second  */
stmfd sp!,{r0-r3}
ldr r0,=firstrnd
bl printf
ldmfd sp!,{r0-r3}

/* Print first team */
ldrb r1,[r0]

bl print_match

/* Get first number of goals */
ldr r0,=scanpattern
ldr r1,=res1
bl scanf

/* Print second team */
ldr r0,[sp]
ldrb r1,[r0,#0x1]

bl print_match

/* Get second number of goals */
ldr r0,=scanpattern
ldr r1,=res2
bl scanf 

/* Assign points (load number of goals in r0 and r1 and the teams' ranking
 * entries in r2 and r3*/
ldr r0,=res1
ldrb r0,[r0]
ldr r1,=res2
ldrb r1,[r1]

eor r5,r5
mov r6,#0x1
ldrb r2,[r4,r5]
ldrb r3,[r4,r6]

bl assign_points

/* Second vs third  */
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

/* Print the group's rank */
ldmfd sp!,{r0}
bl print_rank 

ldmfd sp!,{r3-r6,lr}
bx lr

/* Function to print teams */
print_match:
stmfd sp!,{r4,lr}

/* r1 stores the team's name, in order to print it: r1=word, r2=number  */
and r2,r1,#0xF
and r1,r1,#0xF0
eor r4,r4
add r1,r4,r1,lsr #0x4

/* Convert in ascii */
add r1,r1,#0x37
add r2,r2,#0x30
ldr r0,=str
bl printf

ldmfd sp!,{r4,lr}
bx lr

/* Function to assign points */
assign_points:
stmfd sp!,{r0-r3,lr}

/* Check which group has scored the highest number of goals */
cmp r0,r1

/* If the first team has scored less goals than the second, jump to lessgoals
 *if instead they've scored the same amount of goals, go to equgoals */
bmi lessgoals
beq equgoals

/* If we're here, it means that the first team has won */
add r2,r2,#0x3
b moveon

/* If we're here, it means that the second team has won */
lessgoals:

add r3,r3,#0x3
b moveon

/* I we're here, it means the game ended with a tie, but we've to see if
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

strb r2,[r4,r5]
strb r3,[r4,r6]

ldmfd sp!,{r0-r3,lr}
bx lr

/* Function to reorder and print rank */
print_rank:
stmfd sp!,{r5-r8,lr}

/* Reorder rank: load each team and each team's points, r5:first team, r1:first
 * team's points, and so on */
ldrb r1,[r4]
ldrb r2,[r4,#0x1]
ldrb r3,[r4,#0x2]
ldrb r5,[r0]
ldrb r6,[r0,#0x1]
ldrb r7,[r0,#0x2]

/* Compare first team's points with the second one: if the first has less points * then swap the two (both in the ranking and in the point's ranking) */
cmp r1,r2
bge scndcmp
mov r8,r5
mov r5,r6
mov r6,r8
mov r8,r1
mov r1,r2
mov r2,r8

/* Compare first team's points with the third one: if the first has less
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

/* Finally, check also second and third team and the subscription as well
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

mov r5,#0x3
eor r6,r6

loop:

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

ldr r4,=group1
ldrb r4,[r4,#0x1]
ldr r5,=group2
ldrb r5,[r5,#0x1]
ldr r6,=group3
ldrb r6,[r6,#0x1]

/* Start by loading the second classified in group A inside r3  */
mov r3,r4

/* Compare second classified in group A's points with second classified in
 * group C's points, if minor, save the latter in r3  */ 
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
 * number of goals */
stmfd sp!,{r0-r3}
bl printf
ldmfd sp!,{r0-r3}

stmfd sp!,{r0-r3}
bl print_match

ldr r0,=scanpattern
ldr r1,=res1
bl scanf

ldmfd sp!,{r0-r3}

/* And then ask for the second team's number of goals */
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
 * IS ALLOWED), then store the winner in memory */
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

/* Play the final */
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
	.global main

main:

	stmfd sp!,{lr}
	
	/* Begin group A matches */
	stmfd sp!,{r0-r3}
	ldr r0,=msg1
	bl printf
	ldmfd sp!,{r0-r3}

	/* r0 will be the pointer to the group base address, 
	 * r4 the one to the points array */
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

	/* Check who's the fourth */
	ldr r0,=point1
	ldr r1,=point2
	ldr r2,=point3
	ldrb r0,[r0,#0x1]
	ldrb r1,[r1,#0x1]
	ldrb r2,[r2,#0x1]
	
	bl find_fourth

	/* Play semifinals */
	ldr r0,=semi1msg
	ldr r3,=semi1
	ldr r1,=group1
	ldrb r1,[r1]
	ldr r2,=group2
	ldrb r2,[r2]

	bl semifinals

	ldr r0,=semi2msg
	ldr r3,=semi2
	ldr r1,=group3
	ldrb r1,[r1]
	ldr r2,=fourth
	ldrb r2,[r2]

	bl semifinals

	/* Play final */
	ldr r0,=finmsg
	ldr r1,=semi1
	ldrb r1,[r1]
	ldr r2,=semi2
	ldrb r2,[r2]

	bl final

	ldmfd sp!,{lr}
	bx lr
