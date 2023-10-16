extends Node

## This script tracks the game variables

signal move_bricks_up
signal dragged_brick(brick: TouchScreenButton, direction: brick_direction)
signal speed_changed

const max_rows: int = 12
const bricks_in_row: int = 5
const row_start_pos := Vector2(-300, 680)

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
	get:
		return brick_speed

var row_array: Array[Array] = []

var timer: Timer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	randomize()
	create_row()
	make_timer()
	connect("dragged_brick", handle_brick_drag)


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
	print("You lose the game!")


func handle_brick_drag(brick: TouchScreenButton, direction: brick_direction) -> void:
	# Prints can be removed but for now are useful to keep track of the running code
	print("\nReceived brick info:\nBrick Color: " + brick.brick_color)
	if direction == brick_direction.RIGHT:
		print("Direction: Right")
	else:
		print("Direction: Left")
	
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
					print("Brick Row: ", brick_row_pos.x)
					print("Brick pos: ", brick_row_pos.y)
					# We only need the break here because the variable is incremented as the loop runs.
					found_brick = true
					break
	
	swap_bricks(brick_row_pos, direction, brick)


func swap_bricks(brick_row_pos: Vector2, direction: brick_direction, brick: TouchScreenButton) -> void:
	var brick_to_swap: TouchScreenButton
	
	## Place the dragged brick back into the array, one place left or right of 
	## it's original position.
	var brick_holder: TouchScreenButton = null
	if direction == brick_direction.RIGHT:
		if brick_row_pos.y + 1 > bricks_in_row - 1:
			return
		brick_holder = row_array[brick_row_pos.x][1][brick_row_pos.y + 1]
		row_array[brick_row_pos.x][1][brick_row_pos.y + 1] = brick
		row_array[brick_row_pos.x][1][brick_row_pos.y] = brick_holder
	elif direction == brick_direction.LEFT:
		if brick_row_pos.y - 1 < 0:
			return
		brick_holder = row_array[brick_row_pos.x][1][brick_row_pos.y - 1]
		row_array[brick_row_pos.x][1][brick_row_pos.y - 1] = brick
		row_array[brick_row_pos.x][1][brick_row_pos.y] = brick_holder
	
	brick_to_swap = row_array[brick_row_pos.x][1][brick_row_pos.y]
	var old_pos: Vector2 = brick.position
	brick.position = brick_to_swap.position
	brick_to_swap.position = old_pos
