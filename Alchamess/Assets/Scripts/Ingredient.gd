extends CharacterBody2D

@export var ingredientType = "null"
@export var ingredientSprite : Texture

var is_grabbed : bool = false

# A signal to send to the cauldron when an ingredient touches the pot
signal ingredient_added


func _ready() -> void:
	$Sprite2D.texture = ingredientSprite


func _process(delta):
	if is_grabbed:
		global_position = get_global_mouse_position()


func _input_event(viewport, event, shape_idx) -> void:
	# Checks if the ingredient has been grabbed
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_grabbed = true
			else:
				is_grabbed = false
				return_ingredient_to_start()


# Detecting if the ingredient is placed in the cauldron
func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_grabbed:
		ingredient_added.emit(name)
		is_grabbed = false
		
		# Returning the ingredients to their starting positions
		return_ingredient_to_start()


# Returning the relevant ingredient to their starting positions
func return_ingredient_to_start() -> void:
	match ingredientType:
		"EyeOfNewt":
			global_position = Vector2(262, 280)

		"Wormwood":
			global_position = Vector2(1658, 280)

		"ElbowGrease":
			global_position = Vector2(262, 494)

		"PhoenixFeather":
			global_position = Vector2(1658, 492)

		"OilOfVitriol":
			global_position = Vector2(262, 707)

		"Stardust":
			global_position = Vector2(1658, 705)
