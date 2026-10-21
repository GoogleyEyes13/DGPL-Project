extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $Sprite
@onready var croak: AudioStreamPlayer = $Croak1Mid
@onready var FrogMentor: AnimatedSprite2D = $Sprite
@onready var FrogTongue: Node2D = $"../FrogTongue"

@onready var FrogPhoenixFeather: CanvasItem = $"../FrogTongueIngredients/PhoenixFeather"
@onready var FrogStardust: CanvasItem = $"../FrogTongueIngredients/Stardust"

@onready var ShelfPhoenixFeather: CanvasItem = $"../Ingredients/PhoenixFeather"
@onready var ShelfStardust: CanvasItem = $"../Ingredients/Stardust"

var original_scale: Vector2
var squish_tween: Tween

# Queue to handle concurrent or rapid-fire unlocks cleanly
var unlock_queue: Array[String] = []
var is_fetching: bool = false
var pending_click_ingredient: String = ""


func _ready() -> void:
	original_scale = animated_sprite.scale
	input_pickable = true
	
	FrogMentor.frame = 0
	FrogTongue.visible = false
	
	# Ensure tongue ingredient icons start hidden
	if FrogPhoenixFeather:
		FrogPhoenixFeather.visible = false
	if FrogStardust:
		FrogStardust.visible = false
		
	PotionJournal.NewIngredientUnlocked.connect(_on_new_ingredient_unlocked)


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		squish()


func squish() -> void:
	if squish_tween and squish_tween.is_running():
		squish_tween.kill()

	animated_sprite.scale = original_scale

	squish_tween = create_tween()
	squish_tween.tween_property(animated_sprite, "scale", original_scale * Vector2(1.2, 0.7), 0.08)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	
	if croak:
		croak.play()
	
	squish_tween.tween_property(animated_sprite, "scale", original_scale, 0.15)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)


func _on_new_ingredient_unlocked(ingredient_name: String) -> void:
	# Avoid adding duplicate ingredients to queue if already pending/shelved
	if ingredient_name == "PhoenixFeather" and ShelfPhoenixFeather and ShelfPhoenixFeather.visible:
		return
	if ingredient_name == "Stardust" and ShelfStardust and ShelfStardust.visible:
		return
	if unlock_queue.has(ingredient_name) or pending_click_ingredient == ingredient_name:
		return

	unlock_queue.append(ingredient_name)
	_process_unlock_queue()


func _process_unlock_queue() -> void:
	if is_fetching or unlock_queue.is_empty() or pending_click_ingredient != "":
		return

	is_fetching = true
	var ingredient_name: String = unlock_queue.pop_front()
	pending_click_ingredient = ingredient_name

	FrogMentor.frame = 1
	FrogTongue.visible = true
	FrogTongue.scale.y = 0.003

	# Stretch tongue outward
	var stretch_tween = create_tween()
	stretch_tween.tween_property(FrogTongue, "scale:y", 0.226, 0.45)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	await stretch_tween.finished

	# Pause extended
	await get_tree().create_timer(0.6).timeout

	# Retract tongue
	var retract_tween = create_tween()
	retract_tween.tween_property(FrogTongue, "scale:y", 0.003, 0.45)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	await retract_tween.finished

	# Reveal the ingredient on the frog's mouth/tongue for player to click
	if ingredient_name == "PhoenixFeather" and FrogPhoenixFeather:
		FrogPhoenixFeather.visible = true
	elif ingredient_name == "Stardust" and FrogStardust:
		FrogStardust.visible = true

	is_fetching = false


func _on_new_ingredient_clicked(ingredient_name: String) -> void:
	if pending_click_ingredient != ingredient_name:
		# If clicked manually or through button signal while not active
		if ingredient_name == "PhoenixFeather" and FrogPhoenixFeather and not FrogPhoenixFeather.visible:
			return
		if ingredient_name == "Stardust" and FrogStardust and not FrogStardust.visible:
			return

	FrogTongue.visible = false
	pending_click_ingredient = ""

	# Put onto shelf
	if ingredient_name == "PhoenixFeather":
		if ShelfPhoenixFeather:
			ShelfPhoenixFeather.visible = true
		if FrogPhoenixFeather:
			FrogPhoenixFeather.visible = false
	elif ingredient_name == "Stardust":
		if ShelfStardust:
			ShelfStardust.visible = true
		if FrogStardust:
			FrogStardust.visible = false

	# If more items are waiting in queue, stay open and fetch the next; otherwise close mouth
	if not unlock_queue.is_empty():
		_process_unlock_queue()
	else:
		FrogMentor.frame = 0


func _on_phoenix_feather_pressed() -> void:
	_on_new_ingredient_clicked("PhoenixFeather")


func _on_stardust_pressed() -> void:
	_on_new_ingredient_clicked("Stardust")
