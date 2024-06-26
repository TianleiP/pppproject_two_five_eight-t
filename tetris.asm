################ CSC258H1F Winter 2024 Assembly Final Project ##################
# This file contains our implementation of Tetris.
#
# Student 1: Kai Lim, 1008599544
# Student 2: Tianlei Pang, 1008751307
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    80
# - Display height in pixels:   160
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
    
pause_symbol:
    .space 32

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

# Run the Tetris game.    
main:    

#initialize the game
li $a0, 0x0000ff        #store blue for painting wall
li $a1, 0x1f1f1f        #store grey for painting grids
li $a2, 0xff0000        #store red for drawing the tetramino
li $s3, 0       #initialize time decreaser with 0

#address for the keyboard
lw $t1, ADDR_KBRD

# Starting address for the display
lw $t0, ADDR_DSPL

li $t2 48       #store horizontal line length

#initialize two horizontal walls
li $t5, 960     #offset added to $t0 to draw the horizontal line
add $t5 $t5 $t0     #offset added to display address to represent first unit in the last row
li $t4, 0       #initialize loop index

draw_horizontal_walls:
    bge $t4, 12, initialize_draw_vertical       #if loop index exceeds display width, start drawing vertical walls
    sw $a0 0($t5)       #paint unit blue
    addi $t4 $t4 1      #increment loop index by 1
    addi $t5 $t5 4      #next unit
    j draw_horizontal_walls     #jump back to start of loop
    
initialize_draw_vertical:       #reload the values into register for drawing vertical wall.
    li $t5, 0       #initialize vertical wall drawing offset
    li $t4, 0       #loop index for vertical walls
    add $t5 $t5 $t0     #sets position to paint vertical wall unit
    j draw_vertical_walls       #jump to painting vertical wall unit
    
#draw left and right vertical walls simultaneously
draw_vertical_walls:
    bge $t4, 20, initialize_draw_grid        #after reaching the 21th row, the last row, start drawing the grids
    sw $a0 0($t5)       #paint left vertical wall unit blue
    sw $a0 44($t5)      #paint right vertical wall unit blue
    addi $t5 $t5 48     #add offset to start on next row
    addi $t4 $t4 1      #increment loop counter
    j draw_vertical_walls       #reloop to paint next row walls
    
#draw grid 2 rows at a time
initialize_draw_grid:       #initialize for drawing grid on line of even index, say line 0, line 2, etc.
    li $t4, 0       #still the loop index, we draw 5 white units on each row, so t4 won't exceed 5
    li $t5, 4       #this is for drawing on rows with even index, say row 0
    li $t6, 52      #this is for drawing on rows with odd index, say row 19(last row we have beside the wall)
    add $t5 $t5 $t0     #initialize offset
    add $t6 $t6 $t5     #initialize offset
    la $t3,0        #this is important, it keep track of whether all 20 lines are covered by white units. 
    j draw_grid     #start drawing grid

reset_loop_draw_grid:       #reset the loop index to zero, increment $t3 to keep track of rows being drawn, add offset to t5 and t6.
    li $t4, 0       #reset row loop index to 0
    addi $t5 $t5 56     #add offset to start on first of next two rows
    addi $t6 $t6 56     #add offset to start on second of next two rows
    addi $t3 $t3 1      #increment double row counter
    
draw_grid:
    bge $t4, 5, reset_loop_draw_grid     #finished with row, reset initializations for next two rows
    bge $t3, 10, draw_red_lines     #after finishing the grid, we successfully set up the bitmap and go to the game loop
    addi $t4 $t4 1      #increment row loop counter
    sw $a1 0($t5)       #paint grid unit of first current row grey
    sw $a1 0($t6)       #paint grid unit of second current row grey
    addi $t5 $t5 8      #increment to start painting next grid unit of first current row
    addi $t6 $t6 8      #increment to start painting next grid unit of second current row
    j draw_grid     #reloop to paint next two rows
    
    #the play field is drawn
draw_red_lines:
li $t5 0
li $t4 0
li $t3 724
add $t3 $t3 $t0
j draw_red_lines_loop



draw_red_lines_loop:
    beq $t4 10 reset_redline
    addi $t4 $t4 1
    sw $a2 0($t3)
    addi $t3 $t3 4
    j draw_red_lines_loop
    

reset_redline:
    li $t4 0
    addi $t5 $t5 1
    addi $t3 $t3 8
    beq $t5 5 draw_random_lines
    j draw_red_lines_loop
    


draw_random_lines:#draw five random line at the bottom
    li $v0 42
    li $a0 0
    li $a1 5
    syscall
    add $t3 $a0 $zero
    sll $t3, $t3, 3
    add $t3 $t3 $t0
    addi $t3 $t3 724
    li $t4 0x000000
    sw $t4 0($t3)
    
    li $v0 42
    li $a0 0
    li $a1 5
    syscall
    add $t4 $a0 $zero
    sll $t4, $t4, 3
    add $t4 $t4 $t0
    addi $t4 $t4 772
    li $t3 0x1f1f1f
    sw $t3 0($t4)
    
    li $v0 42
    li $a0 0
    li $a1 5
    syscall
    add $t5 $a0 $zero
    sll $t5, $t5, 3
    add $t5 $t5 $t0
    addi $t5 $t5 820
    li $t3 0x000000
    sw $t3 0($t5)
    
    add $t5 $a0 $zero
    sll $t5, $t5, 1
    li $v0 42
    li $a0 0
    li $a1 5
    syscall
    add $t6 $a0 $zero
    sll $t6, $t6, 3
    add $t6 $t6 $t0
    addi $t6 $t6 868
    li $t3 0x1f1f1f
    sw $t3 0($t6)
    
    add $t6 $a0 $zero
    sll $t6, $t6, 1
    li $v0 42
    li $a0 0
    li $a1 5
    syscall
    add $t7 $a0 $zero
    sll $t7, $t7, 3
    add $t7 $t7 $t0
    addi $t7 $t7 916
    li $t3 0x000000
    sw $t3 0($t7)
    
    #reset variables
    li $a0, 0x0000ff        #store blue for painting wall
    li $a1, 0x1f1f1f        #store grey for painting grids
    li $a2, 0xff0000        #store red for drawing the tetramino
    j game_loop
#variable usage: 
#$t0 is for offset of the bitmap
#$t1 is for offset of keyboard input
#$t2 store 48(line length)
#$t3 store the address of left most or bottom block of the tetramino
#$t4 keep track of orientation. There are four orientation, whe t4 is 0 or 2, the tetramino is horizontal. when t4 is 1 or 3, it's vertical
    #if $t4 = 0, 2, $t3 is the address of the leftmost block. if $t4 = 1, 3, $t3 is the address of the bottom block.
#$t8 is used to check keyboard input


game_loop:
    jal block_landing_sound
    
    #$a0, $a1, $a2, $t0, $t1, $t2 are used to store some basic numbers/addresses (check line41-49), so don't alter the content of these registers
    
    
    #the codes below are for drawing, moving, handling collision with wall and other tetraminos
    #You most likely don't need to look at these codes, it won't affect the implementation of removing lines.
    
    j initialize_check_lines
    
initialize_check_lines:     #initialize values for check_lines loop
    li $t5 19       #keep track of line number, loop from 19 to 0
    li $t4 0        #keep track the number of unit we check in each line(0-10)
    li $t3 0
    add $t3 $t3 $t0
    addi $t3 $t3 916        #second unit at the 20th row(skip the wall)
    j check_lines

reset_check_lines:
    addi $t5 $t5 -1     #decrement row counter for next row
    beq $t5 0 move      #when we reach line 0, exit the loop
    mult $t3 $t5 $t2        #t3 = t5*48, start of current row
    add $t3 $t3 $t0     #offset by display address
    addi $t3 $t3 4      #incremement unit position(next unit)
    li $t4 0        #initialize red units counter to 0
    j check_lines
    
check_lines:        #checks the current row
    beq $t4 10 erase        #check if all units have been red, then erase
    lw $t6 0($t3)       #initialize current position to $t6
    addi $t4 $t4 1      #increment number of units
    addi $t3 $t3 4      #increment current unit position
    beq $t6 $a1 reset_check_lines       #if current unit is grey start on next line
    beq $t6 0x000000 reset_check_lines
    j check_lines
    
erase:
    #at this point, $t5 is storing the current line number
    # I will reset the address store in $t3
    
    mult $t3 $t5 $t2        #t3 = t5*48
    add $t3 $t3 $t0     #first unit in row to erase
    addi $t3 $t3 4      #skip the wall
    
    add $t6 $zero $t5       #t6 is a temporary variable that stores the line num so we dont need to change the content of $t5
    li $t4 0        #when $t4 go to 10, we jump to the line above
    jal line_completed_sound
    j animation

animation:
    li $t7 0xffffff #white
    sw $t7 0($t3)
    sw $t7 4($t3)
    sw $t7 8($t3)
    sw $t7 12($t3)
    sw $t7 16($t3)
    sw $t7 20($t3)
    sw $t7 24($t3)
    sw $t7 28($t3)
    sw $t7 32($t3)
    sw $t7 36($t3)
    j sleep1
continue_animation:
    sw $a2 0($t3)
    sw $a2 4($t3)
    sw $a2 8($t3)
    sw $a2 12($t3)
    sw $a2 16($t3)
    sw $a2 20($t3)
    sw $a2 24($t3)
    sw $a2 28($t3)
    sw $a2 32($t3)
    sw $a2 36($t3)
    j sleep2
continue_animation2:
    sw $t7 0($t3)
    sw $t7 4($t3)
    sw $t7 8($t3)
    sw $t7 12($t3)
    sw $t7 16($t3)
    sw $t7 20($t3)
    sw $t7 24($t3)
    sw $t7 28($t3)
    sw $t7 32($t3)
    sw $t7 36($t3)
    j sleep3
    

sleep3:
    li $t8, 0                # Loop counter
    li $t9, 500000         # Approximate loop count for 1 second; adjust as needed for your system
    j sleep_loop3
    
sleep_loop3:
    addi $t8, $t8, 1         # Increment loop counter
    beq $t8, $t9, erase_loop # Keep looping until the counter reaches the target
    j sleep_loop3
    
sleep2:
    li $t8, 0                # Loop counter
    li $t9, 500000        # Approximate loop count for 1 second; adjust as needed for your system
    j sleep_loop2
    
sleep_loop2:
    addi $t8, $t8, 1         # Increment loop counter
    beq $t8, $t9, continue_animation2 # Keep looping until the counter reaches the target
    j sleep_loop2
    
sleep1:
    li $t8, 0                # Loop counter
    li $t9, 5000000         # Approximate loop count for 1 second; adjust as needed for your system
    j sleep_loop
    
sleep_loop:
    addi $t8, $t8, 1         # Increment loop counter
    beq $t8, $t9, continue_animation # Keep looping until the counter reaches the target
    j sleep_loop
    
reset_erase_loop:
    addi $t6 $t6 -1     #decrement row number
    beq $t6 0 back_to_checkline     #if back at first row, reset and start checking rows again
    li $t4 0
    mult $t3 $t6 $t2 #t3 = t6*48
    add $t3 $t3 $t0
    addi $t3 $t3 4
    j erase_loop
    
erase_loop:
    beq $t4 10 reset_erase_loop     #if erase loop has completed the row, reset
    lw $t7 -48($t3)     #check row above to move it down
    beq $t7 0x000000 draw_grey
    beq $t7 $a2 draw_red
    beq $t7 $a1 draw_black
    
continue_erase_loop:        #increment values and continue erasing
    addi $t3 $t3 4
    addi $t4 $t4 1
    j erase_loop
    
draw_grey:      #paint the unit grey 
    sw $a1 0($t3)
    j continue_erase_loop

draw_black:     #paint the unit black
    li $a3 0x00000
    sw $a3 0($t3)
    j continue_erase_loop

draw_red:       #paint the unit red
    sw $a2 0($t3)
    j continue_erase_loop
    
back_to_checkline:      #start again at beginning row
    j redraw_first_line
    
back_to_checkline_continue:
    mult $t3 $t5 $t2 #t3 = t5*48
    add $t3 $t3 $t0
    addi $t3 $t3 4
    li $t4 0
    j check_lines
    
redraw_first_line:
    li $t7 0x000000
    sw $t7 8($t0)
    sw $t7 16($t0)
    sw $t7 24($t0)
    sw $t7 32($t0)
    sw $t7 40($t0)
    sw $a1 4($t0)
    sw $a1 12($t0)
    sw $a1 20($t0)
    sw $a1 28($t0)
    sw $a1 36($t0)
    j back_to_checkline_continue
    
    
move:       #use to make moves for tetraminos
#set up for moving tetraminos
    jal check_game_over
    li $t4 0        #default orientation: horizontal
    li $t3 16       #address of the first unit of the tetramino
    add $t3 $t3 $t0
    #draw the tetramino at the top of the bitmap
    sw $a2 0($t3)
    sw $a2 4($t3)
    sw $a2 8($t3)
    sw $a2 12($t3)
     
    j check_keypress
    
check_game_over:
    lw $t6, 4($t0)
    beq $t6, $a2, game_over
    lw $t6, 8($t0)
    beq $t6, $a2, game_over
    lw $t6, 12($t0)
    beq $t6, $a2, game_over
    lw $t6, 16($t0)
    beq $t6, $a2, game_over
    lw $t6, 20($t0)
    beq $t6, $a2, game_over
    lw $t6, 24($t0)
    beq $t6, $a2, game_over
    lw $t6, 28($t0)
    beq $t6, $a2, game_over
    lw $t6, 32($t0)
    beq $t6, $a2, game_over
    lw $t6, 36($t0)
    beq $t6, $a2, game_over
    lw $t6, 40($t0)
    beq $t6, $a2, game_over
    jr $ra
    
game_over:
    jal game_over_sound
    jal draw_game_over
    j check_restart
    
check_restart:
    lw $t8, 0($t1)                  #load first word from keyboard
	beq $t8, 1, check_if_r      #if first word 1, key is pressed
	j check_restart
	
check_if_r:
    lw $t9, 4($t1)                  #load second word from keyboard
    beq $t9, 114, initialize_reset_playfield      #check if the key r was pressed and if so rerun main
    j check_restart
    
check_keypress:     #check if key has been pressed
	lw $t8, 0($t1)                  #load first word from keyboard
	beq $t8, 1, keyboard_input      #if first word 1, key is pressed
	j delay_one_second     #time delay for gravity
	
delay_one_second:
    li $t7, 0                #initialize counter
    li $t9, 10000000         #set up loop count for time
    sub $t9, $t9, $s3       #subtract value from loop counter to decrease time loop for current speed
    bge $t9, 1500001, shorten_delay     #if time loop is greater than 1000001 shorten delay loop(increase speed)

    jal delay_loop      #start delay loop

    j check_keypress        #jump to key input when loop is complete
    
shorten_delay:      #decrease delay to increase speed
    addi $s3, $s3, 100000       #increment value to subtract from time loop(increase speed); change this value to increase/decrease speed acceler
    jal delay_loop      #start delay loop
    j check_keypress
    
delay_loop:
    addi $t7, $t7, 1        #increment counter
    bne $t7, $t9, delay_loop        #loop until counter reaches the target value
    beq $t7, $t9, respond_to_s      #make tetramino go down one unit
    jr $ra      #return from the function	


check_unpause:
    lw $t8, 0($t1)      #load first word from keyboard
	beq $t8, 1, check_p        #check if the key pressed is p
	j check_unpause
    
check_p:
    lw $t9, 4($t1)      #load next key press from keyboard
    beq $t9, 112, unpause       #if key is p, unpause
    j check_unpause     #reloop and keep checking for p

unpause:
    jal remove_pause_symbol
    j check_keypress        #resume game

respond_to_p:
    jal draw_pause_symbol
    j check_unpause     #start pause loop
    
draw_pause_symbol:
    #initialize pause symbol stuff
    li $a3, 0xffffff
    li $s2, 400
    add $s2, $s2, $t0
    la $s5, pause_symbol    
    #save first line
    lw $s1, 0($s2)
    sw $s1, 0($s5)
    lw $s1, 48($s2)
    sw $s1, 4($s5)
    lw $s1,96($s2)
    sw $s1, 8($s5)
    lw $s1, 144($s2)
    sw $s1, 12($s5)
    #save second line
    lw $s1, 12($s2)
    sw $s1, 16($s5)
    lw $s1, 60($s2)
    sw $s1, 20($s5)
    lw $s1, 108($s2)
    sw $s1, 24($s5)
    lw $s1, 156($s2)
    sw $s1, 28($s5)
    #draw line 1
    li $s1, 400
    add $s1, $s1, $t0
    sw $a3, 0($s1)
    sw $a3, 48($s1)
    sw $a3, 96($s1)
    sw $a3, 144($s1)
    #draw line 2
    sw $a3, 12($s1)
    sw $a3, 60($s1)
    sw $a3, 108($s1)
    sw $a3, 156($s1)
    
    lw $t1, ADDR_KBRD       #reload keyboard address

    jr $ra
    

remove_pause_symbol:
    li $s1, 400
    add $s1, $s1, $t0
    la $s5, pause_symbol
    #redraw original unit colors for line 1
    lw $s2, 0($s5)
    sw $s2, 0($s1)
    lw $s2, 4($s5)
    sw $s2, 48($s1)
    lw $s2, 8($s5)
    sw $s2, 96($s1)
    lw $s2, 12($s5)
    sw $s2, 144($s1)
    #redraw original unit colors for line 2
    lw $s2, 16($s5)
    sw $s2, 12($s1)
    lw $s2, 20($s5)
    sw $s2, 60($s1)
    lw $s2, 24($s5)
    sw $s2, 108($s1)
    lw $s2, 28($s5)
    sw $s2, 156($s1)
    
    jr $ra    

keyboard_input:  #a key is pressed
    lw $t9, 4($t1)                  #load second word from keyboard
    #check which key has been pressed
    beq $t9, 113, respond_to_q      #check if the key q was pressed
    beq $t9, 100, respond_to_d     #check if the key d was pressed
    beq $t9, 97, respond_to_a        #check if the key a was pressed
    beq $t9, 119, respond_to_w       #check if the key w was pressed
    beq $t9, 115, respond_to_s       #check if the key s was pressed
    beq $t9, 112, respond_to_p
    
    j exit

respond_to_d:       #move right
    beq $t4, 0, respond_to_d_horizontal
    beq $t4, 2, respond_to_d_horizontal
    #if not, the tetramino is vertical in orientation, handle the case in another way
    lw $t5 4($t3)       #position of tetramino bottom unit
    beq $t5, $a0, check_keypress        #collide with the wall
    beq $t5, $a2, check_keypress        #collide with existing tetramino
    lw $t5 -44($t3)     #position of tetramino 2nd from bottom unit
    beq $t5, $a0, check_keypress        #collide with the wall
    beq $t5, $a2, check_keypress        #collide with existing tetramino
    lw $t5 -92($t3)     #position of tetramino 3rd from bottom unit
    beq $t5, $a0, check_keypress        #collide with the wall
    beq $t5, $a2, check_keypress        #collide with existing tetramino
    lw $t5 -140($t3)        #position of tetramino 4th from bottom unit
    beq $t5, $a0, check_keypress        #collide with the wall
    beq $t5, $a2, check_keypress        #collide with existing tetramino
    #no collision occurred
    #re-draw field
    sw $t5 0($t3)       #remove tetramino bottom unit
    sw $t5 -96($t3)     #remove tetramino 3rd from bottom unit
    lw $t5 4($t3)
    sw $t5 -48($t3)     #remove tetramino 2nd from bottom unit
    sw $t5 -144($t3)        #remove tetramino 4th from bottom unit
    #draw the tetramino
    addi $t3 $t3 4
    sw $a2 0($t3)
    sw $a2 -48($t3)     #draw tetramino bottom unit
    sw $a2 -96($t3)     #draw tetramino 2nd from bottom unit
    sw $a2 -144($t3)        #draw tetramino 3rd from bottom unit
    lw $t5 48($t3)      #draw tetramino 4th from bottom unit
    beq $t5, $a2, game_loop     #collide with existing tetramino
    j check_keypress
    
    
respond_to_d_horizontal:
    #if the tetramino can move right, it means that the unit at the right side of the tetramino is not wall or other tetramino
    lw $t5 16($t3)      #retrive the color at the unit on the right side of the tetramino
    beq $t5, $a0, check_keypress        #collide with the wall
    beq $t5, $a2, check_keypress        #collide with existing tetramino
    sw $t5 0($t3)       #maintain color of the grid cells
    
    addi $t3 $t3 4
    sw $a2 0($t3)       #draw in new location
    sw $a2 4($t3)
    sw $a2 8($t3)
    sw $a2 12($t3)
    lw $t5 48($t3)
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    lw $t5 52($t3)
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    lw $t5 56($t3)
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    lw $t5 60($t3)
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    j check_keypress
    
    
respond_to_a:       #move left
    beq $t4, 0, respond_to_a_horizontal
    beq $t4, 2, respond_to_a_horizontal
    #if not, handle the case when tetramino is vertical
    lw $t5 -4($t3)
    beq $t5, $a0, check_keypress        #collide with the wall
    beq $t5, $a2, check_keypress        #collide with existing tetramino
    lw $t5 -52($t3)
    beq $t5, $a0, check_keypress        #collide with the wall
    beq $t5, $a2, check_keypress        #collide with existing tetramino
    lw $t5 -100($t3)
    beq $t5, $a0, check_keypress        #collide with the wall
    beq $t5, $a2, check_keypress        #collide with existing tetramino
    lw $t5 -148($t3)
    beq $t5, $a0, check_keypress        #collide with the wall
    beq $t5, $a2, check_keypress        #collide with existing tetramino
    #no collision occur
    #re-draw field
    sw $t5 0($t3)
    sw $t5 -96($t3)
    lw $t5 -4($t3)
    sw $t5 -48($t3)
    sw $t5 -144($t3)
    #draw the tetramino
    addi $t3 $t3 -4
    sw $a2 0($t3)
    sw $a2 -48($t3)
    sw $a2 -96($t3)
    sw $a2 -144($t3)
    lw $t5 48($t3)
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    j check_keypress
    
    

respond_to_a_horizontal:
    #if the tetramino can move left, it means that the unit at the left side of the tetramino is not wall or other tetramino
    lw $t5 -4($t3)      #retrive the color at the unit on the left side of the tetramino
    beq $t5, $a0, check_keypress        #collide with the wall
    beq $t5, $a2, check_keypress        #collide with existing tetramino
    sw $t5 12($t3)      #maintain color of the grid cells
    addi $t3 $t3 -4
    sw $a2 0($t3)       #draw in new location
    sw $a2 4($t3)
    sw $a2 8($t3)
    sw $a2 12($t3)
    lw $t5 48($t3)
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    lw $t5 52($t3)
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    lw $t5 56($t3)
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    lw $t5 60($t3)
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    j check_keypress

    
respond_to_w:       #rotation
    jal rotation_sound
    beq $t4, 0, handle_rotation_horizontal0
    beq $t4, 1, handle_rotation_vertical1
    beq $t4, 2, handle_rotation_horizontal2
    beq $t4, 3, handle_rotation_vertical3

handle_rotation_horizontal0:        #rotation from horizontal to vertical. clockwise rotation around the second block
    sub $t6 $t3 $t0     #$t6 = $t3-$t0
    div $t6, $t2        #divide $t6 by 48
    mflo $t6      #move the quotient from the LO register to $t6
    beq $t6, $zero check_keypress       #this is the first line, we don't make rotation
    bge $t6, 18, check_keypress     #no rotation when line index >= 18
    addi $t7 $t3 4      #let $t7 be the address of the block of rotation
    #check if the block above the second block contain existing tetramino
    lw $t5 -48($t7)
    beq $t5, $a2, check_keypress        #the block above the second block is occupied. no rotation
    lw $t5 48($t7)
    beq $t5, $a2, check_keypress        #the block under the second block is occupied. no rotation
    lw $t5 96($t7)
    beq $t5, $a2, check_keypress        #the bottom block of ratation is occupied, no rotation
    addi $t4 $t4 1
    #draw colors of grids on the field
    lw $t5 48($t7)
    sw $t5 -4($t7)
    sw $t5 4($t7)
    lw $t5 96($t7)
    sw $t5 8($t7)
    #draw the tetramino
    sw $a2 -48($t7)
    sw $a2 48($t7)
    sw $a2 96($t7)
    addi $t3 $t7 96     #update $t3
    lw $t5 48($t3)
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    j check_keypress
    

    
    
handle_rotation_vertical1:
    addi $t7 $t3 -96        #let $t7 be the address of block of rotation
    #check occpupied units by wall or by existing tetramino
    lw $t5 4($t7)
    beq $t5 $a0 check_keypress
    beq $t5 $a2 check_keypress
    lw $t5 -4($t7) 
    beq $t5 $a0 check_keypress
    beq $t5 $a2 check_keypress
    lw $t5 -8($t7)
    beq $t5 $a0 check_keypress
    beq $t5 $a2 check_keypress
    #we can actually do the rotation
    addi $t4 $t4 1
    #re-draw the color of grids
    lw $t5 -4($t7) 
    sw $t5 48($t7)
    sw $t5 -48($t7)
    lw $t5 -8($t7) 
    sw $t5 96($t7)
    #draw the tetramino
    sw $a2 4($t7)
    sw $a2 -4($t7)
    sw $a2 -8($t7)
    addi $t3 $t7 -8     #update $t3 to the left most unit
    j check_keypress
    
    
    
    
    
    

handle_rotation_horizontal2:
    sub $t6 $t3 $t0     #$t6 = $t3-$t0
    div $t6, $t2        #divide $t6 by 48
    mflo $t6      #move the quotient from the LO register to $t6
    beq $t6, $zero check_keypress       #this is the first line, we don't make rotation
    beq $t6, 1 check_keypress       #this is the second line, we don't make rotation
    bge $t6, 19, check_keypress     #no rotation when line index >= 19
    addi $t7 $t3 8      #let $t7 be the address of the block of rotation
    
    lw $t5 -48($t7)     #check if the block above the third block contain existing tetramino
    beq $t5, $a2, check_keypress        #the block above the third block is occupied. no rotation
    lw $t5 48($t7)
    beq $t5, $a2, check_keypress        #the block under the third block is occupied. no rotation
    lw $t5 -96($t7)
    beq $t5, $a2, check_keypress        #the top block of ratation is occupied, no rotation
    addi $t4 $t4 1
    #draw colors of grids on the field
    lw $t5 48($t7)
    sw $t5 -4($t7)
    sw $t5 4($t7)
    lw $t5 -96($t7)
    sw $t5 -8($t7)
    #draw the tetramino
    sw $a2 -48($t7)
    sw $a2 48($t7)
    sw $a2 -96($t7)
    addi $t3 $t7 48
    lw $t5 48($t3)
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    j check_keypress
    
    

handle_rotation_vertical3:
    addi $t7 $t3 -48        #let $t7 be the address of block of rotation
    #check occpupied units by wall or by existing tetramino
    lw $t5 4($t7)
    beq $t5 $a0 check_keypress
    beq $t5 $a2 check_keypress
    lw $t5 -4($t7) 
    beq $t5 $a0 check_keypress
    beq $t5 $a2 check_keypress
    lw $t5 8($t7)
    beq $t5 $a0 check_keypress
    beq $t5 $a2 check_keypress
    #we can actually do the rotation
    li $t4 0
    #re-draw the color of grids
    lw $t5 -4($t7) 
    sw $t5 48($t7)
    sw $t5 -48($t7)
    lw $t5 8($t7) 
    sw $t5 -96($t7)
    #draw the tetramino
    sw $a2 4($t7)
    sw $a2 -4($t7)
    sw $a2 8($t7)
    addi $t3 $t7 -4     #update $t3 to the left most unit
    j check_keypress
    


respond_to_s:#move down
    beq $t4, 0, respond_to_s_horizontal
    beq $t4, 2, respond_to_s_horizontal
    #if not, handle the vertical case
    lw $t5 48($t3)
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    sw $t5 -144($t3)        #redraw the field
    #draw the tetramino
    addi $t3 $t3 48
    sw $a2 0($t3)
    lw $t5 48($t3)
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    j check_keypress
    
    
respond_to_s_horizontal:
    #if the tetramino can move down, it means that the units below the tetramino are not wall or other tetramino
    lw $t5 48($t3)      #retrive the color at the unit below the tetramino
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    lw $t5 52($t3)      #retrive the color at the unit below the tetramino
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    lw $t5 56($t3)      #retrive the color at the unit below the tetramino
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    lw $t5 60($t3)      #retrive the color at the unit below the tetramino
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    lw $t6 48($t3)      #store the color below the leftmost unit ot the tetramino
    sw $t5 0($t3)       #here, t5 is the color just below the right most unit of the tetramino
    sw $t5 0($t3)
    sw $t5 8($t3)
    sw $t6 4($t3)
    sw $t6 12($t3)
    
    addi $t3 $t3 48
    sw $a2 0($t3)       #draw in new location
    sw $a2 4($t3)
    sw $a2 8($t3)
    sw $a2 12($t3)
    
    lw $t5 48($t3)
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    lw $t5 52($t3)
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    lw $t5 56($t3)
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    lw $t5 60($t3)
    beq $t5, $a0, game_loop     #collide with the wall
    beq $t5, $a2, game_loop     #collide with existing tetramino
    j check_keypress
    
respond_to_q:
    li $v0, 10      #quit game
	syscall
    
game_over_sound:
    li $v0, 31      #async play note syscall
    li $a0, 50      #midi pitch
    li $a1, 50       #duration
    li $a2, 14      #instrument
    li $a3, 100     #volume
    syscall
    li $a0, 0x0000ff        #store blue for painting wall
    li $a1, 0x1f1f1f        #store grey for painting grids
    li $a2, 0xff0000        #store red for drawing the tetramino
    jr $ra
    
line_completed_sound:
    li $v0, 31      #async play note syscall
    li $a0, 50      #midi pitch
    li $a1, 100     #duration
    li $a2, 19      #instrument
    li $a3, 100     #volume
    syscall
    li $a0, 0x0000ff        #store blue for painting wall
    li $a1, 0x1f1f1f        #store grey for painting grids
    li $a2, 0xff0000        #store red for drawing the tetramino
    jr $ra
    
block_landing_sound:
    li $v0, 31      #async play note syscall
    li $a0, 40      #midi pitch
    li $a1, 2       #duration
    li $a2, 13      #instrument
    li $a3, 100     #volume
    syscall
    li $a0, 0x0000ff        #store blue for painting wall
    li $a1, 0x1f1f1f        #store grey for painting grids
    li $a2, 0xff0000        #store red for drawing the tetramino
    jr $ra

rotation_sound:
    li $v0, 31      #async play note syscall
    li $a0, 90      #midi pitch
    li $a1, 1       #duration
    li $a2, 17      #instrument
    li $a3, 100     #volume
    syscall
    li $a0, 0x0000ff        #store blue for painting wall
    li $a1, 0x1f1f1f        #store grey for painting grids
    li $a2, 0xff0000        #store red for drawing the tetramino
    jr $ra

initialize_reset_playfield:
    lw $s6, ADDR_DSPL    # Load the base address of the display into $a0
    li $s7, 0              # Counter for squares
    li $a3, 0x000000       # Color black
    
    j reset_play_field

reset_play_field:
    beq $s7, 252, main
    sw $a3, 0($s6)

    addi $s7, $s7, 1
    addi $s6, $s6, 4
    j reset_play_field

draw_game_over:
    #initialize GG symbol stuff
    li $a3, 0xffffff
    li $s1, 212
    add $s1, $s1, $t0
    #draw first G
    sw $a3, 0($s1)
    sw $a3, 4($s1)
    sw $a3, 8($s1)
    sw $a3, 44($s1)
    sw $a3, 92($s1)
    sw $a3, 100($s1)
    sw $a3, 104($s1)
    sw $a3, 140($s1)
    sw $a3, 152($s1)
    sw $a3, 192($s1)
    sw $a3, 196($s1)
    sw $a3, 200($s1)
    #draw second G
    addi $s1, $s1, 288
    sw $a3, 0($s1)
    sw $a3, 4($s1)
    sw $a3, 8($s1)
    sw $a3, 44($s1)
    sw $a3, 92($s1)
    sw $a3, 100($s1)
    sw $a3, 104($s1)
    sw $a3, 140($s1)
    sw $a3, 152($s1)
    sw $a3, 192($s1)
    sw $a3, 196($s1)
    sw $a3, 200($s1)
    
    lw $t1, ADDR_KBRD       #reload keyboard address

    jr $ra

exit:
