//Wahaj Hassan
//CPSC 355 Assignment 6
//Student ID - 10136892

                                        // Defining the values
                                            
definitions:    define(READ, 3)
                define(OPEN, 5)
                define(CLOSE, 6)
                define(BUFFERSIZE, 8)
                define(term_fr,  d2)
                define(limit_fr, d4)
                define(sum_fr, d6)
                define(fp, x29)         //frame pointer
                

.section        ".data"
                .align  8

precisionBound:	.double 0r1.0e-10
floatingZero:	.double	0r0.0
floatingOne:      .double	0r1.0


badArgument:    .asciz  "Please provide exactly ONE filename on the command line.\n"
                .align  4

ePositiveX:     .asciz  "\nx\t\t\te^x\n"
                .align  4

eNegativeX:     .asciz  "\n\t\t\te^-x\n"
                .align  4

output:         .asciz  "\n%.10f\t%.10f\t\n"
                .align  4


EOFreached:     .asciz  "E.O.F."
                .align  4

.section        ".text"
                .align  4
                
            // Local variables
local_var
var(fill,   8)
var(buffer, BUFFERSIZE, 1)
var(product,    4)



begin_fn(exp)                                             // Definition for exponentiation function
                fmovs	d12,  d10                        // Setting up floating point registers to hold values
                fmovs	d13,  d11

expComputing:   cmp     x0, 1                           // Testing for whether last multiplication has been reached
                ble	expComputingDone                // If so, skip decrement and mult
                

                sub     x0, 1,  x0                  // x0 contains the x to be raised. Using as a counter for number of mults

                fmuld	d12,  d10,    d12             // Multiplying

                ba      expComputing                    // Continuing the loop
                

expComputingDone:                                       // Ending the function and return

end_fn(exp)

begin_fn(factorial)                                    // Defining for factorial function
                mov     1,  w0                         // Setting up registers
                mov     1,  w1                         // Current product of factorial

factComputing:  smul	w0,    w1, w1                  // Multiplying
                inc	w0                             // Increasing for next mult

                cmp     w0, x0                          // Contains upper bound of factorial computation
                ble     factComputing                   // Continue to the loop
                

                st      w1, [x29 + product]             // Storing the factorial product in memory
                ld      [x29 + product],    d14          // Storing the factorial product to floating point register
                fitod	d14,  d14                        // Converting factorial product to double
                
end_fn(factorial)

begin_fn(printePositiveX)                               // Prints the products for e^x
                set     output, w0                      // Setting output string
                std     d0, [x29 + fill]                // f0 is the input from file
                ld      [x29 + fill],   w1              // First half of original double
                ld      [x29 + fill + 4],   w2          // Second half of original double

                std     sum_fr, [x29 + fill]            // Replacing, in memory, the original double with the computed sum
                ld      [x29 + fill],   w3              // First half of sum
                ld      [x29 + fill + 4],	w4            // second half of sum

                call    printf                          // Print
                
end_fn(printePositiveX)

begin_fn(printeNegativeX)                               // Same as above but it is for the e^-x products
                set     output, w0
                std     d20,    [x29 + fill]
                ld      [x29 + fill],       w1
                ld      [x29 + fill + 4],   w2

                std     sum_fr, [x29 + fill]
                ld      [x29 + fill],   w3
                ld      [x29 + fill + 4],   w4

                call    printf
                
end_fn(printeNegativeX)

begin_main()                                                            // Main 
                cmp     x0, 2                           // Must be exactly 2 arguments
                be      valid                                           // Skipping error and exiting if valid
                

                set     badArgument, w0                         // Printing error message and exit, if error
                call    printf
                

                call    exit
                

valid:          set     ePositiveX, w0                         // Printing heading
                call    printf
                

                ld      [x1 + 4],   w0                         // Loading and open file

                clr     w1
                clr     w2
                mov     OPEN,   x30
                ta      0

                mov     w0, x10                         // If not opened correctly, exit immediately. Else, continue to opening.
                bcc     opening
                

                mov     1,  x30
                ta      0

opening:        mov     x10,    w0                         // Opening the file
                add     x29,    buffer, w1                  // Getting address of buffer
                mov     BUFFERSIZE, w2
                mov     READ,   x30                         // Telling the system to read

                addcc	w0,   0,  x8
                bg      reading                              // File i opened, read
                

                ba      finished                            // File opening has failed, abort
                

reading:        set     precisionBound, w0                   // Specifying the precisionBound (10e-10)
                ldd     [w0],   limit_fr                    // Loading it and put it into floating point register

                set     floatingZero,   w0                  // Provide floating point implementation of 0
                ldd     [w0],   sum_fr                      // Setting it as current sum before beginning computation

                ldd     [x29 + buffer], d0                 // Begin reading

                mov     1,  x12                         // First exponent to be raised is 1

sumComputing:   set     floatingZero,   w0                         // Initialize w0 to hold the value of the current term. x12 will determine which term
                ldd	[w0],   term_fr                     // Loading it to floating point register

                fmovs	d0,   d10                        // Temporary fp registers for computing term value
                fmovs	d1,   d11

                mov	x12,    w0                         // Computing the exponent
                call 	exp
                

                mov	x12,    w0                         // Computing the factorial
                call	factorial
                

                fdivd	d10,  d14,  term_fr               // Dividing to get value of term, put it in there

                faddd	term_fr,  sum_fr, sum_fr          // Add the term value into the register holding current sum

                inc	x12                               // Incrementing to compute next term

                fcmpd	term_fr,  limit_fr                // Keep looping until precision bound is reached
                

                fbl	done                              // If it is reached, branch to done
                

                ba	sumComputing                      // If not then loop
                

done:           set	floatingOne,    w0                // These lines add the remaining 1 into the sum in order to account for the 0th term
                ldd	[w0],   d8

                faddd	d8,   sum_fr, sum_fr

                call    printePositiveX
                

validN:         set     eNegativeX, w0                         // Printing the heading
                call    printf
                

                ld      [x1 + 4],   w0                         // Loading and opening file

                clr     w1
                clr     w2
                mov     OPEN,   x30
                ta      0

                mov     w0,     x10                         // If improperly opened, exit immediately. Else, continue to opening.
                bcc     openingN
                

                mov     1,  x30
                ta      0

sumComputingN:  set     floatingZero,   w0               // Initializing w0 to hold the value of the current term. x12 will determine which term
                ldd	[w0],   term_fr                     // Loading it to floating point register

                fmovs	d0,   d10                        // Temporary frame pointer registers for computing term value
                fmovs	d1,   d11

                mov	x12,    w0                         // Computing exponent
                call 	exp
                

                mov	x12,    w0                         // Computing factorial
                call	factorial
                

                fdivd	d10,  d14,    term_fr             // Dividing to get value of term,

                faddd	term_fr,  sum_fr, sum_fr      // Add the term value into the register holding current sum

                inc	x12                                             // Incrementing to compute the next term

                fcmpd	term_fr,  limit_fr                    // Keep looping until precision bound is reached
                

                fbl	doneN                                           // If it is reached then branch to done
                

                ba	sumComputingN                                     // If not then loop
                
doneN:          set	floatingOne,    w0                         // These lines add the remaining 1 into the sum in order to account for the 0th term
                ldd	[w0],    d8

                faddd	d8,   sum_fr, sum_fr

                call    printeNegativeX
                

finished:       set     EOFreached, w0                  // Printing EOF message and exiting.
                call    printf
                

end_main()