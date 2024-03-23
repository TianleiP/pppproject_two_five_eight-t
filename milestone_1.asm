# Assume $gp is the base address for the display, and each wall unit is 8 pixels
# Assume $a0 is used for the color value of the wall
#two register that store color
li $a0, 0x0000ff #for painting wall
li $a1, 0xffffff#for painting grids
# for tracking if it reach the end of the row
li $t1, 48#length of a row
# Starting address for the display
li $t0, 0x10008000
#initialize two horizontal wall offsets
li $t5, 960#offset added to $t0 to draw the horizontal line

add $t5 $t5 $t0#this represent the offset of the first unit in the last row

#loop index
li $t4, 0#loop index
draw_horizontal_walls:
    bge $t4, $t1, initialize # if loop index exceeds display width, start drawing vertical walls
    sw $a0 0($t5)
    addi $t4 $t4 4
    addi $t5 $t5 4
    j draw_horizontal_walls            # jump back to start of loop
    
initialize:#reload the values into register for drawing vertical wall.
    li $t5, 0
    li $t4, 0#still the loop index
    add $t5 $t5 $t0 
    j draw_vertical_walls
    
    
# # Draw left and right walls
draw_vertical_walls:
    bge $t4, 20, initialize_2#after reaching the 21th row, draw the grids
    sw $a0 0($t5)
    sw $a0 44($t5)
    addi $t5 $t5 48
    addi $t4 $t4 1
    j draw_vertical_walls
    
initialize_2:#initialize for drawing grid on line of even idex, say line 0, line 2, etc.
    li $t4, 0#still the loop index, we draw 5 white units on each row, so t4 won't exceed 5
    li $t5, 0
    add $t5 $t5 $t0
    la $t3,0#this is impoetant, it keep track of whether all 20 lines are covered by white units. 
    j draw_grid_1
    
 #keep track of row
    
# #draw grid
draw_grid_1:
    bge $t4, 5, initialize_3 #go to the initialization for drawing on row at odd index
    bge $t3, 20, exit#when all 20 rows are reached
    addi $t4 $t4 1
    sw $a1 4($t5)
    addi $t5 $t5 8
    j draw_grid_1

initialize_3:#initialization that draw grids on rows at odd index, say row 1, row 19(the last row just above the horizontal wall)
    li $t4, 0
    addi $t3 $t3 1 #increment $t3 by 1
    addi $t5 $t5 16
    j draw_grid_2

draw_grid_2:
    bge $t4, 5, initialize_4 #go to the initialization process of draw_grid_1
    addi $t4 $t4 1
    sw $a1 0($t5)
    addi $t5 $t5 8
    j draw_grid_2

initialize_4:#note: here i dont use initialize 2 because i don't wanna reset the value in $t5, which keep track of position of white units
    li $t4, 0
    addi $t3 $t3 1 #increment $t3 by 1
    j draw_grid_1
    



exit:
    # Exit or continue with the rest of the game setup