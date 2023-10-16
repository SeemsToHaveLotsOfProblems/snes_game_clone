extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = translate_brick_speed()
	Global.connect("speed_changed", update_speed)


func update_speed() -> void:
	text = translate_brick_speed()

func translate_brick_speed() -> String:
	var speed_level: int = 0
	match Global.brick_speed:
		5:
			speed_level = 1
		4:
			speed_level = 2
		3:
			speed_level = 3
		2:
			speed_level = 4
		1:
			speed_level = 5
	return str(speed_level)
