extends RichTextLabel


func _ready() -> void:
	Global.gained_points.connect(update_score)


func update_score() -> void:
	text = str(Global.current_points).pad_zeros(4)
