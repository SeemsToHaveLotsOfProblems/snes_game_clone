extends Node

# This should equal teh size of the sprite + a small buffer like 5 pixels or so.
const brick_size: int = 241

@onready var root_node: TouchScreenButton = $".."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.connect("move_bricks_up", move_up)


func set_initial_position(row: Node2D, pos: int) -> void:
	# Will find the correct position to place the brick
	if root_node == null:
		root_node = $".."
	root_node.position = Vector2(row.position.x + (pos * brick_size), row.position.y)


func move_up() -> void:
	root_node.position = Vector2(root_node.position.x, root_node.position.y - brick_size)
