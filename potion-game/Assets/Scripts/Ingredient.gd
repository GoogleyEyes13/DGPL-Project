extends CharacterBody2D

var is_grabbed : bool = false
var starting_pos = position

func _process(delta):
	if is_grabbed:
		# Checks if the left mouse button has been released
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			is_grabbed = false
			position = starting_pos
			return
		
		# Moves the ingredient with the mouse if grabbed
		var mouse_pos = get_global_mouse_position()
		global_position = lerp(global_position, mouse_pos, 0.2)
		return
		
func _input_event(viewport, event, shape_idx) -> void:
	# Checks if the ingredient has been grabbed
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_grabbed = true
		else:
			is_grabbed = false
			position = starting_pos
			
