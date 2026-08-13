extends CharacterBody2D

var is_grabbed : bool = false

func _process(delta):
	if is_grabbed:
		# Checks if the left mouse button has been released
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			is_grabbed = false
			
			# Returning the ingredients to their starting positions
			match name:
				"EyeOfNewt":
					global_position = Vector2(157, 171)
				"Wormwood":
					global_position = Vector2(994, 170)
				"MagicPebble":
					global_position = Vector2(157, 299)
				"PhoenixFeather":
					global_position = Vector2(994, 298)
				"OilOfVitriol":
					global_position = Vector2(157, 427)
				"Stardust":
					global_position = Vector2(994, 426)
			
			return
		
		# Moves the ingredient with the mouse if grabbed
		var mouse_pos = get_global_mouse_position()
		global_position = lerp(global_position, mouse_pos, 0.2)
		return
		
func _input_event(viewport, event, shape_idx) -> void:
	# Checks if the ingredient has been grabbed
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_grabbed = true

# Detecting if the ingredient is placed in the cauldron
func _on_detection_area_body_entered(body: Node2D) -> void:
	if is_grabbed:
		print(name, " has been placed in the pot")
