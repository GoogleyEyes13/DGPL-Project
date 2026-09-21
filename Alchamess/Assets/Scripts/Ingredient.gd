extends CharacterBody2D

@export var ingredientType = "null"
@export var ingredientSprite : Texture2D

var is_grabbed : bool = false

func _ready() -> void:
	$Sprite2D.texture = ingredientSprite
	$Sprite2D.visible = false


func _process(_delta):
	if is_grabbed:
		global_position = get_global_mouse_position()


func _input_event(_viewport, event, _shape_idx) -> void:
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
			global_position = Vector2(391, 254)
		"Wormwood":
			global_position = Vector2(1548, 254)
		"ElbowGrease":
			global_position = Vector2(387, 481)
		"PhoenixFeather":
			global_position = Vector2(1538, 477)
		"OilOfVitriol":
			global_position = Vector2(397, 672)
		"Stardust":
			global_position = Vector2(1540, 672)
