extends TouchScreenButton

# The amount of pixels the game will ignore when you start to drag.
const dead_zone: int = 50

@onready var brick_color: String = %ColorPicker.brick_color
@onready var anim_player: AnimationPlayer = %AnimationPlayer
var draging: bool = false

var swipe_start: Vector2 = Vector2.ZERO
var swipe_end: Vector2 = Vector2.ZERO

# Used for grabbing the event from unhandled_input
var current_event: InputEvent


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag and not draging:
		if self.is_pressed():
			swipe_start = event.position
			draging = true
			current_event = event
	if draging and event.is_released():
		swipe_end = event.position


func _on_released() -> void:
	if draging:
		handle_swipe()
		await get_tree().create_timer(0.2).timeout
		draging = false


func handle_swipe() -> void:
#	anim_player.play("Move")
#	await anim_player.animation_finished
	if Vector2(swipe_start - swipe_end).x < dead_zone: # Right
		Global.emit_signal("dragged_brick", self, Global.brick_direction.RIGHT)
	elif Vector2(swipe_start - swipe_end).x > dead_zone: # Left
		Global.emit_signal("dragged_brick", self, Global.brick_direction.LEFT)
#	anim_player.play("Drop")



func pop_brick() -> void:
	for row in Global.row_array:
		for brick in row[1]:
			if brick == self:
				brick = null
				Global.bricks_popped += 1
				Global.gain_points()
				self.queue_free()


func _on_animation_player_animation_started(_anim_name: StringName) -> void:
#	if anim_name == "Move":
#		position += Vector2(12.5, 12.5)
	pass
