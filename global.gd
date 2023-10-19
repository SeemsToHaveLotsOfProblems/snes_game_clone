extends Node

## This script tracks the game variables

signal move_bricks_up
signal dragged_brick(brick: TouchScreenButton, direction: brick_direction)
signal speed_changed
signal gained_points

const brick_size: int = 241
const max_rows: int = 12
const bricks_in_row: int = 5
const row_start_pos := Vector2(-300, 680)
const tween_speed: float = 0.2

enum brick_direction{
	RIGHT = 0,
	LEFT = 1,
}

## Nodes are found in the find_nodes() function to prevent issues with this script
## loading in before them.
var game_board: Node2D

var brick_speed: int = 5 :
	set(val):
		brick_speed = val
		emit_signal("speed_changed")
		timer.start(val)
	get:
		return brick_speed

var row_array: Array[Array] = []

var timer: Timer

var bricks_popped: int = 0
var points_per_brick: int = 10
var multiplier: int = 1
var current_points: int = 0 :
	set(val):
		current_points = val
		if bricks_popped % 30 == 0:
			multiplier += 1
		if bricks_popped % 60 == 0: # This won't work but find a way to make it work.
			if not brick_speed == 1:
				brick_speed -= 1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	randomize()
	create_row()
	make_timer()
	dragged_brick.connect(handle_brick_drag)


func gain_points() -> void:
	current_points += points_per_brick * multiplier
	gained_points.emit()


func _input(event: InputEvent) -> void:
	if event.is_action_released("pause") and not get_tree().paused:
		get_tree().paused = true
		timer.paused = true
		print("Game paused!")
	elif event.is_action_released("pause") and get_tree().paused:
		get_tree().paused = false
		timer.paused = false
		print("Game unpaused!")


# Any nodes that I may needs access to can be searched for here.
func find_nodes() -> void:
	game_board = get_tree().get_root().get_node("GameBoard")


func trigger_brick_signals() -> void:
	emit_signal("move_bricks_up")
	create_row()
	check_color_match()
	if row_array.size() >= max_rows:
		gameover()
		return


func create_row() -> void:
	if game_board == null:
		find_nodes()
	var row := Node2D.new()
	game_board.add_child(row)
	row.position = row_start_pos
	var brick: Resource = load("res://brick/brick.tscn")
	var brick_array: Array[TouchScreenButton] = []
	for i in bricks_in_row:
		var brick_instance: TouchScreenButton = brick.instantiate()
		row.add_child(brick_instance)
		brick_instance.get_node("PositionSetter").set_initial_position(row, i)
		brick_array.append(brick_instance)
	row_array.append([row, brick_array])


func make_timer() -> void:
	timer = Timer.new()
	timer.wait_time = brick_speed
	timer.autostart = true
	timer.timeout.connect(trigger_brick_signals)
	if game_board == null:
		find_nodes()
	game_board.add_child(timer)


func gameover() -> void:
	timer.stop()
	get_tree().paused = true
	timer.paused = true
	var text: String = "[center]GAME OVER!\n[center]SCORE: [rainbow]" + str(current_points).pad_zeros(4)
	game_board.get_node("GameOverLabel").text = text
	game_board.get_node("GameOverLabel").visible = true
	print("You lose the game!")


func handle_brick_drag(brick: TouchScreenButton, direction: brick_direction) -> void:
	# Itterate through my bricks to find the row and position.
	@warning_ignore("unassigned_variable")
	var brick_row_pos := Vector2(-1, -1)
	var found_brick: bool = false
	for row in row_array:
		if not found_brick:
			brick_row_pos.x += 1
			brick_row_pos.y = -1
			for _brick in row[1]:
				brick_row_pos.y += 1
				if _brick == brick:
					# We only need the break here because the variable is incremented as the loop runs.
					found_brick = true
					break
	
	swap_bricks(brick_row_pos, direction, brick)
	check_color_match()


func swap_bricks(brick_row_pos: Vector2, direction: brick_direction, brick: TouchScreenButton) -> void:
	var brick_to_swap: TouchScreenButton
	## Place the dragged brick back into the array, one place left or right of 
	## it's original position.
	var brick_holder: TouchScreenButton = null
	if direction == brick_direction.RIGHT:
		if brick_row_pos.y + 1 > bricks_in_row - 1:
			return
		elif row_array[brick_row_pos.x][1][brick_row_pos.y + 1] == null:
			row_array[brick_row_pos.x][1][brick_row_pos.y + 1] = brick
			row_array[brick_row_pos.x][1][brick_row_pos.y] = null
		else:
			brick_holder = row_array[brick_row_pos.x][1][brick_row_pos.y + 1]
			row_array[brick_row_pos.x][1][brick_row_pos.y + 1] = brick
			row_array[brick_row_pos.x][1][brick_row_pos.y] = brick_holder
		
		brick_to_swap = row_array[brick_row_pos.x][1][brick_row_pos.y]
		if brick_to_swap == null:
#			var tween: Tween = get_tree().create_tween()
#			var new_pos: Vector2 = brick.position + Vector2(brick_size, 0)
#			tween.tween_property(brick, "position", new_pos, tween_speed)
#			await  tween.finished
			brick.position += Vector2(brick_size, 0)
	elif direction == brick_direction.LEFT:
		if brick_row_pos.y - 1 < 0:
			return
		elif row_array[brick_row_pos.x][1][brick_row_pos.y - 1] == null:
			row_array[brick_row_pos.x][1][brick_row_pos.y - 1] = brick
			row_array[brick_row_pos.x][1][brick_row_pos.y] = null
		else:
			brick_holder = row_array[brick_row_pos.x][1][brick_row_pos.y - 1]
			row_array[brick_row_pos.x][1][brick_row_pos.y - 1] = brick
			row_array[brick_row_pos.x][1][brick_row_pos.y] = brick_holder
		
		brick_to_swap = row_array[brick_row_pos.x][1][brick_row_pos.y]
		if brick_to_swap == null:
#			var tween: Tween = get_tree().create_tween()
#			var new_pos: Vector2 = brick.position - Vector2(brick_size, 0)
#			tween.tween_property(brick, "position", new_pos, tween_speed)
#			await tween.finished
			brick.position -= Vector2(brick_size, 0)
	
	
	var old_pos: Vector2 = brick.position
	if not brick_to_swap == null:
#		var tween: Tween = get_tree().create_tween()
#		tween.tween_property(brick, "position", brick_to_swap.position, tween_speed)
#		await tween.finished
		brick.position = brick_to_swap.position
#		var tween2: Tween = get_tree().create_tween()
#		tween2.tween_property(brick_to_swap, "position", old_pos, tween_speed)
#		await tween2.finished
		brick_to_swap.position = old_pos


func check_color_match() -> void:
	# Check for 3 or more in a row.
	var brick_match_array: Array[TouchScreenButton] = row_match_checker()
	# Check for 3 or more in a colum
	brick_match_array += colum_match_checker()
	# Pop the matched bricks
	for bricks_to_pop in brick_match_array:
		bricks_to_pop.pop_brick()
	
	drop_floating_bricks()
	check_for_null_row()
	# Update score.


func row_match_checker() -> Array[TouchScreenButton]:
	# Check for 3 or more in a row.
	var brick_match_array: Array[TouchScreenButton] = []
	var temp_brick_match_array: Array[TouchScreenButton] = []
	var match_color: String
	# Itterating through rows
	for row in row_array.size():
		if temp_brick_match_array.size() >= 3:
			for matched in temp_brick_match_array:
				brick_match_array.append(matched)
		# Resetting the match color when rows switch
		match_color = ""
		temp_brick_match_array.clear()
		
		# Itterating through bricks
		for _brick in row_array[row][1]:
			if _brick == null:
				if temp_brick_match_array.size() >= 3:
					brick_match_array += temp_brick_match_array
				temp_brick_match_array.clear()
				continue
			
			if match_color == "":
				match_color = _brick.brick_color
			
			if _brick.brick_color == match_color:
				temp_brick_match_array.append(_brick)
			else:
				match_color = _brick.brick_color
				if temp_brick_match_array.size() >= 3:
					for matched in temp_brick_match_array:
						brick_match_array.append(matched)
				temp_brick_match_array.clear()
				temp_brick_match_array.append(_brick)
	
	# Adding this here as well to watch for the last row in the array.
	if temp_brick_match_array.size() >= 3:
		for matched in temp_brick_match_array:
			brick_match_array.append(matched)
	return brick_match_array


func colum_match_checker() -> Array[TouchScreenButton]:
	var brick_match_array: Array[TouchScreenButton] = []
	var tmp_match_array: Array[TouchScreenButton] = []
	var match_color: String
	
	for col_itr in bricks_in_row:
		for row_itr in row_array:
			if row_itr[1][col_itr] == null:
				if tmp_match_array.size() >= 3:
					brick_match_array += tmp_match_array
				tmp_match_array.clear()
				continue
			
			var brick: TouchScreenButton = row_itr[1][col_itr]
			
			if match_color == "":
				match_color = brick.brick_color
			
			if brick.brick_color == match_color:
				tmp_match_array.append(brick)
			else:
				if tmp_match_array.size() >= 3:
					brick_match_array += tmp_match_array
				tmp_match_array.clear()
				match_color = brick.brick_color
				tmp_match_array.append(brick)
			
			# Ensures that the last colum gets read in too.
			if row_itr == row_array.back():
				if tmp_match_array.size() >= 3:
					brick_match_array += tmp_match_array
				tmp_match_array.clear()
	
	return brick_match_array


# Finds how far down the next brick is and drops any floating bricks.
func drop_floating_bricks() -> bool:
	var did_drop_bricks: bool = true
	var return_value: bool = false
	while did_drop_bricks:
		did_drop_bricks = false
		for col_itr in bricks_in_row:
			for row_itr in row_array.size():
				if row_array[row_itr][1][col_itr] == null:
					continue
				
				var brick: TouchScreenButton = row_array[row_itr][1][col_itr]
				
				if not row_itr + 1 >= row_array.size():
					if row_array[row_itr+1][1][col_itr] == null:
						row_array[row_itr+1][1][col_itr] = brick
						row_array[row_itr][1][col_itr] = null
						brick.position += Vector2(0, brick_size)
						did_drop_bricks = true
						return_value = true
	return return_value


func check_for_null_row() -> void:
	for row in row_array:
		var is_null_row: bool = true
		for brick in row[1]:
			if not brick == null:
				is_null_row = false
		if is_null_row:
			row_array.erase(row)
