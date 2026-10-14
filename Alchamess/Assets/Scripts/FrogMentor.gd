extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $Sprite

var original_scale: Vector2
var squish_tween: Tween

func _ready() -> void:
	original_scale = animated_sprite.scale
	input_pickable = true

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			squish()

func squish() -> void:
	if squish_tween and squish_tween.is_running():
		squish_tween.kill()

	animated_sprite.scale = original_scale

	squish_tween = create_tween()
	squish_tween.tween_property(
		animated_sprite,
		"scale",
		original_scale * Vector2(1.2, 0.7),
		0.08
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	squish_tween.tween_property(
		animated_sprite,
		"scale",
		original_scale,
		0.15
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
