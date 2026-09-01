extends CharacterBody2D

@export var ingredientType = "null"
@export var ingredientSprite : Texture2D

var is_grabbed : bool = false

func _ready() -> void:
	$Sprite2D.texture = ingredientSprite
	$Sprite2D.visible = false


func _process(delta):
	if is_grabbed:
		global_position = get_global_mouse_position()


func _input_event(viewport, event, shape_idx) -> void:
	# Checks if the ingredient has been grabbed
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_grabbed = true
				$Sprite2D.visible = true
			else:
				is_grabbed = false
				$Sprite2D.visible = false
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
