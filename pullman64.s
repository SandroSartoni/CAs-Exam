	.data

.balign 8
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
str x30,[sp,-16]!

ldr x0,=hrmsg
bl printf

ldr x0,=scan_pattern
ldr x1,=H_LEAVE
bl scanf

ldr x1,=H_LEAVE
ldrh w1,[x1]
lsl w1,w1,0x8
ldr x0,=H_LEAVE
strh w1,[x0]

ldr x0,=mntmsg
bl printf

ldr x0,=scan_pattern
ldr x1,=TMP_VAR
bl scanf

ldr x1,=H_LEAVE
ldrh w1,[x1]
ldr x0,=TMP_VAR
ldrb w0,[x0]
add w1,w1,w0
ldr x0,=H_LEAVE
strh w1,[x0]

ldr x30,[sp],16
ret

/* Print the time */
print_time:
stp x1,x6,[sp,-16]!
str x30,[sp,-16]!

/* r1 = hours, r2 = minutes */
and w2,w1,0xFF
lsr w1,w1,0x8

cbnz x6,loadtomorrow
ldr x0,=time
b printtime

loadtomorrow:

ldr x0,=tomorrowtime

printtime:

bl printf

ldr x30,[sp],16
ldp x1,x6,[sp],16
ret

/* Handle the not today case */
not_today:
str x30,[sp,-16]!

add x6,x6,0x1
ldrh w1,[x0]

ldr x30,[sp],16
ret

/* Print the duration of the full trip  */
print_duration:
str x30,[sp,-16]!

ldr x0,=H_LEAVE
ldrh w0,[x0]
mov w4,0xC4

and w2,w0,0xFF
and w3,w1,0xFF

cmp w3,w2
bge keepon
sub w1,w1,w4

keepon:

cbz x6,continue

mov w2,0x18
lsl w2,w2,0x8
add w1,w1,w2

continue:
sub w1,w1,w0

and w2,w1,0xFF
lsr w1,w1,0x8

ldr x0,=durmsg
bl printf

ldr x30,[sp],16
ret

/* Main Section  */

	.global main
	.global printf
/* Remember to mask the bits when loading values from memory */

main:
	str x30, [sp,-16]!

/* Ask the user for H_LEAVE and store it in memory */
	bl take_h_leave 

/* Solution regarding A and B */
	ldr x0,=absol
	bl printf

/* Load from memory H_LEAVE */	
	ldr x2,=H_LEAVE
	ldr w2,[x2]

/* Reset r6 (used to signal if the solution belongs to the next day)  */
	eor x6,x6,x6

/* Start searching in A_SCHED the first available hour  */	
	ldr x0,=A_SCHED
	ldr x4,=N_A
	ldrb w4,[x4]
	eor x5,x5,x5
	eor x7,x7,x7
	
search_a:

	cmp x4,x5
	beq not_today_a
	ldrh w1,[x0,x7]
	add x7,x7,0x2
	add x5,x5,0x1
	cmp w1,w2
	bmi search_a
	b print_a
	
not_today_a:

	bl not_today

print_a:

/* Every time I call printf, I push and pop X1,X6 because they're the
 * the only ones that do not have to be overwritten: X1 stores the time
 * while X6 tells if it's referred to today or tomorrow*/
	stp x1,x6,[sp,-16]!

	ldr x0,=solmsg
	bl printf

	ldp x1,x6,[sp],16

	bl print_time

/* Once we've retrieved from memory the value, add A_TO_B and start searching in B_SCHED  */
	ldr x3,=A_TO_B
	ldrb w3,[x3]
	
	add w1,w1,w3

/* Check for "time overflow" */
	and w3,w1,0xFF
	cmp w3,0x3C
	bmi printswpmsg_ab
	add w1,w1,0xC4

/* Before, we print the arrival time to the swap point  */
printswpmsg_ab:
	
	stp x1,x6,[sp,-16]!

	ldr x0,=swpmsg
	bl printf

	ldp x1,x6,[sp],16

	bl  print_time

/* Check now in B_SCHED table */
	ldr x0,=B_SCHED
	ldr x4,=N_B
	ldrb w4,[x4]
	eor x5,x5,x5
	eor x7,x7,x7

search_b:

	cmp x4,x5
	beq not_today_b
	ldrh w2,[x0,x7]
	add x7,x7,0x2
	add x5,x5,0x1
	cmp w2,w1
	bmi search_b
	mov w1,w2
	b print_b

not_today_b:

	bl not_today

/* Now print the departure time stored in r1  */
print_b:

	stp x1,x6,[sp,-16]!

	ldr x0,=depmsg
	bl printf

	ldp x1,x6,[sp],16

	bl print_time

/* Add B_TO_TP time, check for "time overflow" and print it */

	ldr x0,=B_TO_TP
	ldrb w0,[x0]

	add w1,w1,w0

	and w3,w1,0xFF
	cmp w3,0x3C
	bmi printarrmsg_ab
	add w1,w1,0xC4

printarrmsg_ab:

	stp x1,x6,[sp,-16]!

	ldr x0,=arrmsg
	bl printf

	ldp x1,x6,[sp],16

	bl print_time

	bl print_duration

/* Solution regarding C and D */
	ldr x0,=cdsol
	bl printf

/* Load from memory H_LEAVE */	
	ldr x2,=H_LEAVE
	ldrh w2,[x2]

/* Reset r6 (used to signal if the solution belongs to the next day)  */
	eor x6,x6,x6

/* Start searching in C_SCHED the first available hour  */	
	ldr x0,=C_SCHED
	ldr x4,=N_C
	ldrb w4,[x4]
	eor x5,x5,x5
	eor x7,x7,x7
	
search_c:

	cmp x4,x5
	beq not_today_c
	ldrh w1,[x0,x7]
	add x7,x7,0x2
	add x5,x5,0x1
	cmp w1,w2
	bmi search_c
	b print_c
	
not_today_c:

	bl not_today

print_c:

	stp x1,x6,[sp,-16]!

	ldr x0,=solmsg
	bl printf

	ldp x1,x6,[sp],16

	bl print_time

/* Once we've retrieved from memory the value, add C_TO_D and start searching in D_SCHED  */
	ldr x3,=C_TO_D
	ldrb w3,[x3]
	
	add w1,w1,w3

/* Check for "time overflow" */
	and w3,w1,0xFF
	cmp w3,0x3C
	bmi printswpmsg_cd
	add w1,w1,0xC4

/* Before, we print the arrival time to the swap point  */
printswpmsg_cd:

	stp x1,x6,[sp,-16]!

	ldr x0,=swpmsg
	bl printf

	ldp x1,x6,[sp],16

	bl  print_time

/* Check now in D_SCHED table */
	ldr x0,=D_SCHED
	ldr x4,=N_D
	ldrb w4,[x4]
	eor x5,x5,x5
	eor x7,x7,x7

search_d:

	cmp x4,x5
	beq not_today_d
	ldrh w2,[x0,x7]
	add x7,x7,0x2
	add x5,x5,0x1
	cmp w2,w1
	bmi search_d
	mov w1,w2
	b print_d

not_today_d:

	bl not_today

/* Now print the departure time stored in r1  */
print_d:

	stp x1,x6,[sp,-16]!

	ldr x0,=depmsg
	bl printf

	ldp x1,x6,[sp],16

	bl print_time

/* Add D_TO_TP time, check for "time overflow" and print it */

	ldr x0,=D_TO_TP
	ldrb w0,[x0]

	add w1,w1,w0

	and w3,w1,0xFF
	cmp w3,0x3C
	bmi printarrmsg_cd
	add w1,w1,0xC4

printarrmsg_cd:

	stp x1,x6,[sp,-16]!

	ldr x0,=arrmsg
	bl printf

	ldp x1,x6,[sp],16

	bl print_time
	bl print_duration

/* End of the program */
	ldr x30,[sp],16
	ret
