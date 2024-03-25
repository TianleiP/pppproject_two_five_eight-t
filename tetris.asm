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
    bge $t3, 10, game_loop      #after finishing the grid, we successfully set up the bitmap and go to the game loop
    addi $t4 $t4 1      #increment row loop counter
    sw $a1 0($t5)       #paint grid unit of first current row grey
    sw $a1 0($t6)       #paint grid unit of second current row grey
    addi $t5 $t5 8      #increment to start painting next grid unit of first current row
    addi $t6 $t6 8      #increment to start painting next grid unit of second current row
    j draw_grid     #reloop to paint next two rows
    
    #the play field is drawn
 
#variable usage: 
#$t0 is for offset of the bitmap
#$t1 is for offset of keyboard input
#$t2 store 48(line length)
#$t3 store the address of left most or bottom block of the tetramino
#$t4 keep track of orientation. There are four orientation, whe t4 is 0 or 2, the tetramino is horizontal. when t4 is 1 or 3, it's vertical
    #if $t4 = 0, 2, $t3 is the address of the leftmost block. if $t4 = 1, 3, $t3 is the address of the bottom block.
#$t8 is used to check keyboard input

game_loop:
    #for the remaining portion of milestone 3:
    #Before start moving tetraminos, we need to check if there is any complete line. if there is, need to do something to update/redraw the field
    
    #... basic idea for handling complete line: loop through the whole field from line 19 to line 0
    #if this line is not complete: go to the line above and check
    #else: go to a helper function that let all the red blocks above this line drop by one unit, then check the same line again in next iteration.
    
    #Helper function that "drop" blocks: basic idea: a nested loop that loop through all units within and above this line
    
    #for any line, we loop though all its units(besides the wall). For any unit, if the unit above this unit is red, make this unit red. 
    #if the unit above this unit is black, make this unit grey. if the unit above is grey, make this unit black. 
    #after finishing looping on this line, loop thourgh the line above and do the same thing.
    
    #after the helper function loops thourgh all lines, it jumps back to the original function that call this helper
    
    #$a0, $a1, $a2, $t0, $t1, $t2 are used to store some basic numbers/addresses (check line41-49), so don't alter the content of these registers
    
    
    #the codes below are for drawing, moving, handling collision with wall and other tetraminos
    #You most likely don't need to look at these codes, it won't affect the implementation of removing lines.
    
    #set up for moving tetraminos
     li $t4 0       #default orientation: horizontal
     li $t3 16      #address of the first unit of the tetramino
     add $t3 $t3 $t0
     
     #draw the tetramino at the top of the bitmap
     sw $a2 0($t3)
     sw $a2 4($t3)
     sw $a2 8($t3)
     sw $a2 12($t3)
     
     j move
    
move:       #use to make moves for tetraminos
    j check_keypress
    
check_keypress:     #check if key has been pressed
	lw $t8, 0($t1)                  #load first word from keyboard
	beq $t8, 1, keyboard_input      #if first word 1, key is pressed
	j move

keyboard_input:  #a key is pressed
    lw $t9, 4($t1)                  #load second word from keyboard
    #check which key has been pressed
    beq $t9, 100, respond_to_d     #check if the key d was pressed
    beq $t9, 97, respond_to_a        #check if the key a was pressed
    beq $t9, 119, respond_to_w       #check if the key w was pressed
    beq $t9, 115, respond_to_s       #check if the key s was pressed
    
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
    
    
    


   


exit: