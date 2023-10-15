extends Node

## This script tracks the game variables

signal move_bricks_up

const max_rows: int = 12
const bricks_in_row: int = 5
const row_start_pos := Vector2(-300, 680)

## Nodes are found in the find_nodes() function to prevent issues with this script
## loading in before them.
var game_board: Node2D

var brick_speed: int = 5
var row_array: Array[Array] = []

var timer: Timer

func _ready() -> void:
	randomize()
	create_row()
	make_timer()


# Any nodes that I may needs access to can be searched for here.
func find_nodes() -> void:
	game_board = get_tree().get_root().get_node("GameBoard")


func trigger_brick_signals() -> void:
	if row_array.size() >= max_rows:
		gameover()
		return
	emit_signal("move_bricks_up")
	create_row()


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
	timer.connect("timeout", trigger_brick_signals)
	if game_board == null:
		find_nodes()
	game_board.add_child(timer)


func gameover() -> void:
	timer.stop()
	print("You lose the game!")
	pass
