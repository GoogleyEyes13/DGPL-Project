extends CharacterBody2D

@export var potionType = "null"
@export var potionName = "null"
@export var potionSprite : SpriteFrames
@export var flip_h: bool = false

var is_grabbed : bool = false

func _ready() -> void:
	$AnimatedSprite2D.sprite_frames = potionSprite
	$AnimatedSprite2D.animation = potionType
	$AnimatedSprite2D.flip_h = flip_h


func _process(delta):
	if is_grabbed:
		global_position = get_global_mouse_position()


func _input_event(viewport, event, shape_idx) -> void:
	# Checks if the potion has been grabbed
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_grabbed = true


func _input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed and is_grabbed:
				is_grabbed = false
				return_potion_to_start()


# Returning the relevant potion to their starting positions
func return_potion_to_start() -> void:
	match potionName:
		"Potion1":
			global_position = Vector2(653, 112)
		"Potion1-2":
			global_position = Vector2(1271, 112)
		"Potion2":
			global_position = Vector2(729, 113)
		"Potion2-2":
			global_position = Vector2(1198, 113)
		"Potion3":
			global_position = Vector2(906, 114)
		"Potion4":
			global_position = Vector2(1014, 112)
		"Potion5":
			global_position = Vector2(818, 107)
		"Potion5-2":
			global_position = Vector2(1105, 107)
