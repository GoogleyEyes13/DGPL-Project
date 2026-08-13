extends CharacterBody2D

var is_grabbed := false

var starting_position: Vector2
var grab_mouse_x := 0.0
var grab_stick_x := 0.0

@export var movement_range := 100.0

func _ready():
	starting_position = position


func _process(delta):
	# Checks if the left mouse button has been released
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_grabbed = false
	
	if is_grabbed:
		var mouse_pos = get_global_mouse_position()

		# How far the mouse has moved horizontally since clicking
		var mouse_difference = mouse_pos.x - grab_mouse_x

		# Move the stick by the same amount
		var new_x = grab_stick_x + mouse_difference

		# Clamp movement to 100 pixels left of starting position
		position.x = clamp(
			new_x,
			starting_position.x - movement_range,
			starting_position.x
		)

		# Keep Y unchanged
		position.y = starting_position.y


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_grabbed = true

				# Remember where the mouse and stick were when clicked
				grab_mouse_x = get_global_mouse_position().x
				grab_stick_x = position.x

			else:
				is_grabbed = false
