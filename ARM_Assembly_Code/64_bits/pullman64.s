/* Solution provided by Sandro Sartoni 

Note: there're some differencies between the 64-bits ARM assembly and the 32-bits one. The most immediate regards
the registers: while in 32-bits mode we've 16 registers, r0-r15, each one on 32 bits, here we've 31 registers
x0-x30 plus, in some instructions, we can refer to one more register called SP (stack pointer), each one on 64-bits.
It's possible, eventually, to refer only to the lowest 32-bits, by changing the 'x' with 'w', i.e. w0 instead of x0.
Other differencies will be discussed in the code.

**********************************************************************************************************************************


Exam's text:


Mr Omp uses the public transportation to reach his office at TP®. Basically he has 2 choices; first: take bus A, step off and then
take bus B; second: take bus C, step off and take bus D. Mr Omp knows:
•	the departure schedule of buses A and C referred to the bus stop in front of his house (two arrays called,
	A_SCHED, and B_SCHED, respectively), and the departure schedule of B and D in correspondence of the swap-points
	A-to-B and C-to-D respectively (two arrays called, C_SCHED, and D_SCHED, respectively).

He also knows how long does it take: 
•	for bus A to reach the swap-point A-to-B and for C to reach C-to-D (variable names: A_TO_B and C_TO_D);
•	for busses B and D to reach the building of TP® (variable names: B_TO_TP and D_TO_TP, respectively).

It is requested to write a 8086 assembly program providing Mr. Omp with the fastest travel solution from his house to his
office, depending on the time he exits his house (variable: H_LEAVE). Please consider also that:  
•	The duration of the full trip from the house to the office is less than 24 hours;
•	Each time is stored on 16 bits in the format: 000hhhhh 00mmmmmm, where the 5 h-bits represent the hour in 24-hours
	format (0-23), and the 6 m-bits the minutes (0-59);
•	The arrays A_SCHED, B_SCHED, C_SCHED and D_SCHED are sorted in increasing order (of time), have N_A, N_B, N_C and N_D
	elements (between 4 and 20), are known in advance and are the same all year long.
•	The last ride of the day for each bus line is followed by the first ride of the next day.

Only fully completed items will be considered; given in input H_LEAVE, please solve only one among 1, 2, 3 and 4.

Item 1: POINTS -> 21. Refer to the first choice only (take bus A, step off and then take bus B) and, ASSUMING that there exists
                      a valid solution in the same day (i.e. departure and arrival occurring on the same day), compute & print:
1.	Arrival time to the swap-point;
2.	Departure time from the swap-point; 
3.	Arrival time to the office.

Item 2: POINTS -> 25. Refer to the first choice only, with the CONSTRAINT that the travel should occur in the same day
                      (i.e. departure and arrival taking place on the same day), compute & print:
1.	Name of solution (first or NO valid solution exists in the same day);
2.	Arrival time to the swap-point (if a valid solution exists);
3.	Departure time from the swap-point (if a valid solution exists);
4.	Arrival time to the office (if a valid solution exists).
	Please observe that there could be cases when no solution exists, e.g. because the departure time or arrival
	time to the swap-point are too much late and no further ride exists in the same day.

Item 3: POINTS -> 28. Refer to the two choices with the CONSTRAINT that the travel should occur in the same day
                      (i.e. departure and arrival taking place on the same day), compute & print:
1.	Name of solution (first/second /NO valid solution exists in the same day);
2.	Arrival time to the swap-point (if a valid solution exists);
3.	Departure time from the swap-point (if a valid solution exists);
4.	Arrival time to the office (if a valid solution exists); 
5.	The same information of points (2-4) for the other non-chosen but valid solution (if another one exists).
Please observe that there could be cases when no solution exists, e.g. because the departure time or arrival time
to the swap-point are too much late and no further ride exists in the same day.

Item 4: POINTS -> 32. Refer to the two choices, without any constraint/assumption about the travel occurring in the same day
                      (i.e. departure can be on one day and arrival on the following day), compute & print:
1.	Name of solution (first/second);
2.	Arrival time to the swap-point;
3.	Departure time from the swap-point;
4.	Arrival time to the office; if the arrival is on the day after, a “*” should be printed next to the arrival time;
5.	The same information of points 2-4 for the other (non-chosen) solution.
Please observe that there will be always solutions for both choices A and B, with the arrival either on the same or the
following day. Particular care should be taken when managing arrivals on the following day.  

Bonus Item: Duration of the full trip. POINTS  +2 if Item 1/2/3 has been solved previously; POINTS  +3 if Item 4 has been
            solved previously AND it is managed the case of departure & arrival when they are NOT in the same day. 
Examples: A_TO_B = 16 minutes     B_TO_TP = 29 minutes;     C_TO_D = 4 minutes      D_TO_TP = 45 minutes

Bus	DEPARTURES FROM SELECTED BUS STOP
A		8:10	9:00	9:45	10:30	11:30	12:30	13:15	14:00	15:00	16:00	17:00	18:00
B (by A)	7:10	8:15	9:05	10:40	11:00	14:00	14:30	15:00	15:30	16:15	16:45	17:15
C		8:30	9:40	10:50	12:00	13:10	14:20	15:30	16:40	17:50	19:00	20:10	21:20
D (by C)	7:00	8:40	9:40	10:40	11:40	12:30	13:30	15:00	16:30	18:30	20:30	21:00

•	H_LEAVE = 7:00
o	for the first choice, we have A departing at 8:10, arriving at the swap-point with B at 8:10+A_TO_B= 8:10+16 = 8:26.
        The first available bus B is at 9:05 and therefore the final arrival time is 9:05+B_TO_TP = 9.05+29 = 9:34. Total
	duration of the trip is 9:34-7:00 = 2 hours and 34 minutes
o	for the second choice, we have C departing at 8:30, arriving at the swap-point with D at 8:30+C_TO_D = 8:30+4 = 8:34.
        The first available bus D is at 8:40 and therefore the final arrival time is 8:40+D_TO_TP = 8.40+45 = 9:25. Total duration
	of the trip is 9:25-7:00 = 2 h. and 25 m.
•	H_LEAVE = 16:55
o	for the first choice we have A departing at 17:00, arriving at the swap-point with B at 17:00+A_TO_B = 17:00+16 = 17:16.
        The first available bus B is at 7:10 the next morning; hence the final arrival time is 7:10+B_TO_TP=7:10+29 = 7:39 one day after.
        Total duration is 7:39+24.00-16:55=14 h. and 44 m. 
o	for the second choice, we have C departing at 17:50, arriving at swap-point with D at 17:50+C_TO_D = 17:50+4 = 17:54.
        The first available bus D is at 18:30 and therefore final arrival time is 18:30+D_TO_TP = 18.30+45 = 19:15. Total duration
	of the trip is 19:15-16:55 = 2 h. and 20 m. 
•	H_LEAVE = 21:30
o	for the first choice, we have A departing at 8:10 the next morning, arriving at the swap-point with B at
        8:10+A_TO_B = 8:10+16 = 8:26. The first available bus B is at 9:05 and therefore final arrival time is
	9:05+B_TO_TP = 9.05+29 = 9:34. Total duration is 9:34+24.00-21:30 = 12 h. and 4 m. 
o	for the second choice, we have C departing at 8:30 the next morning, arriving at the swap-point with D at
        8:30+C_TO_D = 8:30+4 = 8:34. The first available bus D is at 8:40 and therefore final arrival time is
	8:40+ D_TO_TP = 8.40+45 = 9:25. Total duration is 9:25+24.00-21:30=11 h. and 55 m. 

HINTS (observe that)
•	The format of the time variables allows direct comparisons (lexicographic order): no need to convert
•	For each bus departure time, the arrival time is deterministic, as well as the duration of the bus time.
        A possible solution could be to pre-compute for each bus departure, the final arrival time and then…
	(As another matter of example, you could think about booking a flight with 2 hops…)

IMPORTANT NOTES AND REQUIREMENTS (SHARP)
•	It is not required to provide the/an optimal solution, but a working and clear one using all information provided.
•	It is required to write at class time a short & clear explanation of the algorithm and significant instruction comments.
•	Input-output is not necessary in class-developed solution, but its implementation is mandatory for the oral exam.
•	Minimum score to “pass” this part is 15 (to be averaged with second part and to yield a value at least 18)
•	To avoid misunderstandings, please consider that, as in the previous calls of the last 5 years (at least) the
        final score reflects the overall evaluation of the code, i.e., fatal errors, such as division by zero (etc) make it
	impossible to reach 30 or larger scores. Specifically, at oral exam, students will request the evaluation of some or
	all the parts that they have solved; prior proceeding to the correction, the points of the parts to be corrected will be
	added up and bounded to max 35. The final score, after the correction of students’ requested items, will be “cut off” to 32.

REQUIREMENTS ON THE I/O PART TO BE DONE AT HOME
•	The databases (if any) have to be defined and initialized inside the code; in this case, all data related to the starting
        time H_LEAVE have to be input from the keyboard (i.e. NOT stored in the array/variables)
•	All inputs and outputs should be in readable ASCII form (no binary is permitted).


*********************************************************************************************************************************       

How to get this file running on Raspberry Pi 3:
After having installed pi64 OS, it's quite easy to get this file running by typing:

as -g -o pullman64.o pullman64.s
gcc -o pullman64 pullman64.o

in the terminal to get the executable, and then to run it: ./pullman64
These commands will work only if executed when inside the same directory of the source files.
*/

/* .data is a directive that allows us to define all the memory variables required in our program */
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
