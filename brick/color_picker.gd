extends Node
## Colors should be semi-random.
## It should always be possible to win.

@onready var root_node: TouchScreenButton = $".."

var color_array: Array[Color] = [
	Color.RED,
	Color.GREEN,
	Color.BLUE,
	Color.YELLOW,
]

var brick_color: String


func _ready() -> void:
	choose_color()


func choose_color() -> void:
	var choice: int = randi() % color_array.size()
	root_node.self_modulate = color_array[choice]
	match choice:
		0:
			brick_color = "Red"
		1:
			brick_color = "Green"
		2:
			brick_color = "Blue"
		3:
			brick_color = "Yellow"
