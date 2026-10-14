extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $Sprite
@onready var croak = $Croak1Mid
@onready var FrogMentor = $Sprite
@onready var FrogTongue = $"../FrogTongue"

@onready var FrogPhoenixFeather = $"../FrogTongueIngredients/PhoenixFeather"
@onready var FrogStardust = $"../FrogTongueIngredients/Stardust"

@onready var ShelfPhoenixFeather = $"../Ingredients/PhoenixFeather"
@onready var ShelfStardust = $"../Ingredients/Stardust"

var original_scale: Vector2
var squish_tween: Tween


func _ready() -> void:
	original_scale = animated_sprite.scale
	input_pickable = true
	
	FrogMentor.frame = 0
	FrogTongue.visible = false
	
	PotionJournal.NewIngredientUnlocked.connect(_on_new_ingredient_unlocked)


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			squish()


func squish() -> void:
	if squish_tween and squish_tween.is_running():
		squish_tween.kill()

	animated_sprite.scale = original_scale

	squish_tween = create_tween()
	squish_tween.tween_property(animated_sprite, "scale", original_scale * Vector2(1.2, 0.7), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	croak.play()
	
	squish_tween.tween_property(animated_sprite,"scale", original_scale, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_new_ingredient_unlocked(ingredient_name: String) -> void:
	FrogMentor.frame = 1
	FrogTongue.visible = true

	# Stretch the tongue outward from its base
	var stretch_tween = create_tween()
	stretch_tween.tween_property(FrogTongue, "scale:y", 0.226, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await stretch_tween.finished

	# Keep the tongue extended while fetching
	await get_tree().create_timer(2.5).timeout

	# Retract the tongue
	var retract_tween = create_tween()
	retract_tween.tween_property(FrogTongue, "scale:y", 0.003, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await retract_tween.finished
		
	if ingredient_name == "PhoenixFeather":
		FrogPhoenixFeather.visible = true
	else:
		FrogStardust.visible = true


func _on_new_ingredient_clicked(ingredient_name: String) -> void:
	FrogTongue.visible = false
	
	if ingredient_name == "PhoenixFeather":
		ShelfPhoenixFeather.visible = true
	elif ingredient_name == "Stardust":
		ShelfStardust.visible = true

	FrogMentor.frame = 0
	FrogPhoenixFeather.visible = false
	FrogStardust.visible = false


func _on_phoenix_feather_pressed() -> void:
	_on_new_ingredient_clicked("PhoenixFeather")


func _on_stardust_pressed() -> void:
	_on_new_ingredient_clicked("Stardust")
