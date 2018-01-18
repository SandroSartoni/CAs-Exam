	.data

.balign 4
absol: .asciz "Solution regarding A and B\n"
cdsol: .asciz "Solution regarding C and D\n"
hrmsg: .asciz "Insert departure hour: "
mntmsg: .asciz "Insert departure minutes: "
solmsg: .asciz "First solution available: "
swpmsg: .asciz "Swap point arrival time: "
depmsg: .asciz "Departure time from swap point: "
durmsg: .asciz "Duration of the full trip: %02d:%02d\n"
arrmsg: .asciz "Arrival time: "
time: .asciz "%02d:%02d\n"
tomorrowtime: .asciz "%02d:%02d*\n"
scan_pattern: .asciz "%d"

A_SCHED: .hword 0x080A, 0x0900, 0x092D, 0x0A1E, 0x0B1E, 0x0C1E, 0x0D0F, 0x0E00
	 .hword 0x0F00, 0x1000, 0x1100, 0x1200

B_SCHED: .hword 0x070A, 0x080F, 0x0905, 0x0A28, 0x0B00, 0x0E00, 0x0E1E, 0x0F00
	 .hword 0x0F1E, 0x100F, 0x102D, 0x110F

C_SCHED: .hword 0x081E, 0x0928, 0x0A32, 0x0C00, 0x0D0A, 0x0E14, 0x0F1E, 0x1028
	 .hword 0x1132, 0x1300, 0x140A, 0x1514

D_SCHED: .hword 0x0700, 0x0828, 0x0928, 0x0A28, 0x0B28, 0x0C1E, 0x0D1E, 0x0F00
	 .hword 0x101E, 0x121E, 0x141E, 0x1500

N_A: .byte 0x0C
N_B: .byte 0x0C
N_C: .byte 0x0C
N_D: .byte 0x0C

A_TO_B: .byte 0x10
B_TO_TP: .byte 0x1D
C_TO_D: .byte 0x04
D_TO_TP: .byte 0x2D

TMP_VAR: .byte 0x00

.balign 4
H_LEAVE: .hword 0x0000


	.text


	.global printf
	.global scanf

/* Ask the user the departure time and store it in memory  */
take_h_leave:
stmfd sp!,{lr}

ldr r0,=hrmsg
bl printf

ldr r0,=scan_pattern
ldr r1,=H_LEAVE
bl scanf

ldr r1,=H_LEAVE
ldrh r1,[r1]
eor r0,r0
add r1,r0,r1,lsl #0x8
ldr r0,=H_LEAVE
strh r1,[r0]

ldr r0,=mntmsg
bl printf

ldr r0,=scan_pattern
ldr r1,=TMP_VAR
bl scanf

ldr r1,=H_LEAVE
ldrh r1,[r1]
ldr r0,=TMP_VAR
ldrb r0,[r0]
add r1,r1,r0
ldr r0,=H_LEAVE
strh r1,[r0]

ldmfd sp!,{lr}
bx lr

/* Print the time */
print_time:
stmfd sp!,{r1,lr}

/* r1 = hours, r2 = minutes */
and r2,r1,#0xFF
eor r0,r0
add r1,r0,r1,lsr #0x8

cmp r6,#0
ldreq r0,=time
ldrne r0,=tomorrowtime
bl printf

ldmfd sp!,{r1,lr}
bx lr

/* Handle the not today case */
not_today:
stmfd sp!,{lr}

add r6,r6,#0x1
ldrh r1,[r0]

ldmfd sp!,{lr}
bx lr

/* Print the duration of the full trip  */
print_duration:
stmfd sp!,{lr}

ldr r0,=H_LEAVE
ldrh r0,[r0]
mov r4,#0xC4

and r2,r0,#0xFF
and r3,r1,#0xFF

cmp r3,r2
submi r1,r1,r4

cmp r6,#0
beq continue

mov r2,#0x18
eor r3,r3
add r2,r3,r2,lsl #0x8
add r1,r1,r2

continue:
sub r1,r1,r0

and r2,r1,#0xFF
eor r0,r0
add r1,r0,r1,lsr #0x8

ldr r0,=durmsg
bl printf

ldmfd sp!,{lr}
bx lr

/* Main Section  */

	.global main

main:
	str lr, [sp,#-4]!

/* Ask the user for H_LEAVE and store it in memory */
	bl take_h_leave 

/* Solution regarding A and B */
	ldr r0,=absol
	bl printf

/* Load from memory H_LEAVE */	
	ldr r2,=H_LEAVE
	ldrh r2,[r2]

/* Reset r6 (used to signal if the solution belongs to the next day)  */
	eor r6,r6

/* Start searching in A_SCHED the first available hour  */	
	ldr r0,=A_SCHED
	ldr r4,=N_A
	ldrb r4,[r4]
	eor r5,r5
	eor r7,r7
	
search_a:

	cmp r4,r5
	beq not_today_a
	ldrh r1,[r0,r7]
	add r7,r7,#0x2
	add r5,r5,#0x1
	cmp r1,r2
	bmi search_a
	b print_a
	
not_today_a:

	bl not_today

print_a:

	stmfd sp!,{r1}
	ldr r0,=solmsg
	bl printf
	ldmfd sp!,{r1}

	bl print_time

/* Once we've retrieved from memory the value, add A_TO_B and start searching in B_SCHED  */
	ldr r3,=A_TO_B
	ldrb r3,[r3]
	
	add r1,r1,r3

/* Check for "time overflow" */
	and r3,r1,#0xFF
	cmp r3,#0x3C
	addge r1,r1,#0xC4

/* Before, we print the arrival time to the swap point  */
	stmfd sp!,{r1}
	ldr r0,=swpmsg
	bl printf
	ldmfd sp!,{r1}

	bl  print_time

/* Check now in B_SCHED table */
	ldr r0,=B_SCHED
	ldr r4,=N_B
	ldrb r4,[r4]
	eor r5,r5
	eor r7,r7

search_b:

	cmp r4,r5
	beq not_today_b
	ldrh r2,[r0,r7]
	add r7,r7,#0x2
	add r5,r5,#0x1
	cmp r2,r1
	bmi search_b
	mov r1,r2
	b print_b

not_today_b:

	bl not_today

/* Now print the departure time stored in r1  */
print_b:

	stmfd sp!,{r1}
	ldr r0,=depmsg
	bl printf
	ldmfd sp!,{r1}

	bl print_time

/* Add B_TO_TP time, check for "time overflow" and print it */

	ldr r0,=B_TO_TP
	ldrb r0,[r0]

	add r1,r1,r0

	and r3,r1,#0xFF
	cmp r3,#0x3C
	addge r1,r1,#0xC4

	stmfd sp!,{r1}
	ldr r0,=arrmsg
	bl printf
	ldmfd sp!,{r1}

	bl print_time

	bl print_duration

/* Solution regarding C and D */
	ldr r0,=cdsol
	bl printf

/* Load from memory H_LEAVE */	
	ldr r2,=H_LEAVE
	ldrh r2,[r2]

/* Reset r6 (used to signal if the solution belongs to the next day)  */
	eor r6,r6

/* Start searching in C_SCHED the first available hour  */	
	ldr r0,=C_SCHED
	ldr r4,=N_C
	ldrb r4,[r4]
	eor r5,r5
	eor r7,r7
	
search_c:

	cmp r4,r5
	beq not_today_c
	ldrh r1,[r0,r7]
	add r7,r7,#0x2
	add r5,r5,#0x1
	cmp r1,r2
	bmi search_c
	b print_c
	
not_today_c:

	bl not_today

print_c:

	stmfd sp!,{r1}
	ldr r0,=solmsg
	bl printf
	ldmfd sp!,{r1}

	bl print_time

/* Once we've retrieved from memory the value, add C_TO_D and start searching in D_SCHED  */
	ldr r3,=C_TO_D
	ldrb r3,[r3]
	
	add r1,r1,r3

/* Check for "time overflow" */
	and r3,r1,#0xFF
	cmp r3,#0x3C
	addge r1,r1,#0xC4

/* Before, we print the arrival time to the swap point  */
	stmfd sp!,{r1}
	ldr r0,=swpmsg
	bl printf
	ldmfd sp!,{r1}

	bl  print_time

/* Check now in D_SCHED table */
	ldr r0,=D_SCHED
	ldr r4,=N_D
	ldrb r4,[r4]
	eor r5,r5
	eor r7,r7

search_d:

	cmp r4,r5
	beq not_today_d
	ldrh r2,[r0,r7]
	add r7,r7,#0x2
	add r5,r5,#0x1
	cmp r2,r1
	bmi search_d
	mov r1,r2
	b print_d

not_today_d:

	bl not_today

/* Now print the departure time stored in r1  */
print_d:

	stmfd sp!,{r1}
	ldr r0,=depmsg
	bl printf
	ldmfd sp!,{r1}

	bl print_time

/* Add D_TO_TP time, check for "time overflow" and print it */

	ldr r0,=D_TO_TP
	ldrb r0,[r0]

	add r1,r1,r0

	and r3,r1,#0xFF
	cmp r3,#0x3C
	addge r1,r1,#0xC4

	stmfd sp!,{r1}
	ldr r0,=arrmsg
	bl printf
	ldmfd sp!,{r1}

	bl print_time
	bl print_duration

/* End of the program */

	ldr lr,[sp],#4
	bx lr
