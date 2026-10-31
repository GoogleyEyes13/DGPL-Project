extends AnimatedSprite2D

#region Variables
var CustomerName: String = "HerbBert"

var start_pos: Vector2
var centre_pos: Vector2
var end_pos: Vector2
var cust_is_ready: bool = false
var original_scale: Vector2
var is_shrunk: bool = false

# Movement
@export var step_bounce_height: float = 8.0
@export var step_speed: float = 6.0
@export var customer_names: Array[String] = ["Queso", "HerbBert", "MrMonicle", "LadyP", "Norkl"]

# Potion effect timing & shake variables
@export var jitter_intensity: float = 4.0
@export var jitter_step_time: float = 0.05
@export var walk_out_duration: float = 3.5

@export var explode_shake_intensity: float = 20.0
@export var explode_shake_duration: float = 0.8
@export var explode_fade_duration: float = 0.2

@onready var SmokeTransition = $"../Smoke"

# Audio
var walk_sounds: Dictionary = {
	"Queso": preload("res://Assets/Audio/SFX/Walking/quesowalkdblspeed.wav"),
}
var default_walk_sound: AudioStream = preload("res://Assets/Audio/SFX/Walking/regularwalkdblspeed.wav")

@onready var walk_sfx: AudioStreamPlayer = $WalkSFX
@onready var smoke_sfx: AudioStreamPlayer = $SmokeSFX

var first_arrival: bool = true
var ending_active: bool = false
#endregion


func _ready() -> void:
	DebugManager.register_customer(self)
	
	var window_size = get_viewport_rect().size
	original_scale = scale
	
	start_pos = Vector2(window_size.x + 200, window_size.y / 2)
	centre_pos = Vector2(window_size.x / 2, window_size.y / 2)
	end_pos = Vector2(-200, window_size.y / 2)
	
	global_position = start_pos
	animation = CustomerName
	frame = 0
	stop()
	
	hide()
	bob_in()
	
	if is_instance_valid(Globals) and not Globals.ending_triggered.is_connected(_on_ending_triggered):
		Globals.ending_triggered.connect(_on_ending_triggered)

func _on_ending_triggered(ending_type: String) -> void:
	if ending_active:
		return
	ending_active = true
	trigger_game_ending(ending_type)


func trigger_opening_dialogue() -> void:
	if DebugManager.skip_dialogue:
		DebugManager.debug_log("Skipping opening tutorial dialogue")
		trigger_customer_dialogue()
		return

	var resource = load("res://Dialogue/Tutorial.dialogue")
	DialogueManager.show_dialogue_balloon(resource)
	await DialogueManager.dialogue_ended
	
	trigger_customer_dialogue()


func trigger_customer_dialogue() -> void:
	Globals.randomizeWantedType()
	if DebugManager.skip_dialogue:
		DebugManager.debug_log("Skipping customer dialogue for " + CustomerName)
		return

	# Single-line resolution with automatic HerbBert fallback via CharacterData
	var dialogue_path = CharacterData.get_dialogue_path(CustomerName)
	DialogueManager.show_dialogue_balloon(load(dialogue_path))


func bob_in() -> void:
	show()
	
	walk_sfx.stream = walk_sounds.get(CustomerName, default_walk_sound)
	walk_sfx.play()
	
	var travel_duration: float = 4.5
	
	var move_tween = create_tween()
	move_tween.tween_property(self, "global_position:x", centre_pos.x, travel_duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	move_tween.tween_callback(on_arrival)
	
	var march_tween = create_tween().set_loops()
	march_tween.tween_property(self, "global_position:y", centre_pos.y - step_bounce_height, 1.0 / step_speed)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	march_tween.tween_property(self, "global_position:y", centre_pos.y, 1.0 / step_speed)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	
	move_tween.tween_callback(march_tween.kill)


func on_arrival() -> void:
	walk_sfx.stop()
	global_position.y = centre_pos.y
	DebugManager.debug_log(CustomerName + " is at the counter! Waiting for interaction...")
	
	cust_is_ready = true
	
	if first_arrival:
		first_arrival = false
	else:
		trigger_customer_dialogue()


func jitter_effect(duration: float) -> void:
	var jitter_tween = create_tween()
	var steps: int = int(duration / jitter_step_time)
	
	for i in steps:
		var jitter_offset = Vector2(
			randf_range(-jitter_intensity, jitter_intensity),
			randf_range(-jitter_intensity, jitter_intensity)
		) / scale
		jitter_tween.tween_property(self, "offset", jitter_offset, jitter_step_time)
	
	jitter_tween.tween_property(self, "offset", Vector2.ZERO, jitter_step_time)


func receive_potion(potion_type: String) -> void:
	DebugManager.debug_log("Potion Received")
	if not cust_is_ready:
		return
	cust_is_ready = false
	
	Globals.submitPotion(potion_type)
	
	var info: Dictionary = PotionDatabase.get_potion_info_by_name(potion_type)
	if info.is_empty():
		push_warning("Unknown potion type: " + potion_type)
		return

	var target_frame: int = info.get("frame", 0)
	
	# Fetch recipe ingredients for the journal & popup
	var ingredients: Array = []
	for recipe_ingredients in PotionDatabase.RECIPES.keys():
		if PotionDatabase.RECIPES[recipe_ingredients]["name"] == potion_type:
			ingredients = recipe_ingredients.duplicate()
			break

	# 1. Register with Journal
	PotionJournal.register_potion(potion_type, ingredients)
	PotionJournal.record_potion_given(potion_type, CustomerName, target_frame)

	# --- 2. SHOW POPUP ON DELIVERY ---
	var popup: PotionPopup = get_tree().get_first_node_in_group("PotionPopup") as PotionPopup
	if popup:
		popup.display_potion(potion_type, ingredients)
	# ---------------------------------

	# Visual effects & smoke transition
	SmokeTransition.visible = true
	SmokeTransition.play()
	smoke_sfx.play()
	
	await get_tree().create_timer(0.3).timeout
	frame = target_frame
	DebugManager.debug_log("Potion effect on customer: " + potion_type)

	var delay_time: float = 1.0

	var effect: String = info.get("effect", "")
	if effect == "explode":
		explode_effect()
		return
	elif effect == "shake":
		delay_time = 1.0
		jitter_effect(delay_time + walk_out_duration)
	
	if info.has("scale"):
		scale = info["scale"]
	
	if potion_type == "Potion of Skeleton" and CustomerName != "Queso":
		scale = Vector2(0.22, 0.22)
	elif potion_type == "Potion of Change Art Styles" and CustomerName == "MrMonicle":
		scale = Vector2(0.24, 0.24)
	elif potion_type == "Potion of Mogging" and CustomerName == "HerbBert":
		scale = Vector2(0.60, 0.60)
		
	if info.get("shrink", false):
		position.y += 45
		is_shrunk = true
	
	var dialogue_path = CharacterData.get_dialogue_path(CustomerName, "Done")
	DialogueManager.show_dialogue_balloon(load(dialogue_path))
	
	await DialogueManager.dialogue_ended
	
	if ending_active:
		return
		
		
	var delay = create_tween()
	delay.tween_interval(delay_time)
	delay.tween_callback(bob_out)


func bob_out() -> void:
	walk_sfx.stream = walk_sounds.get(CustomerName, default_walk_sound)
	walk_sfx.play()
	
	var move_tween = create_tween()
	move_tween.tween_property(self, "global_position:x", end_pos.x, walk_out_duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	move_tween.tween_callback(new_customer)
	
	var bob_y = centre_pos.y
	if is_shrunk:
		bob_y += 45

	var march_tween = create_tween().set_loops()
	march_tween.tween_property(self, "global_position:y", bob_y - step_bounce_height, 1.0 / step_speed)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	march_tween.tween_property(self, "global_position:y", bob_y, 1.0 / step_speed)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)

	move_tween.tween_callback(march_tween.kill)


func new_customer() -> void:
	walk_sfx.stop()
	if customer_names.is_empty():
		push_warning("No customer names assigned!")
		return
	
	modulate.a = 1.0
	scale = Vector2(0.10, 0.10)
	is_shrunk = false

	var next_name: String = customer_names[randi() % customer_names.size()]
	if customer_names.size() > 1:
		while next_name == CustomerName:
			next_name = customer_names[randi() % customer_names.size()]

	CustomerName = next_name
	animation = CustomerName
	stop()

	global_position = start_pos
	cust_is_ready = false
	bob_in()


func explode_effect() -> void:
	walk_sfx.stop()
	customer_names.erase(CustomerName)
	DebugManager.debug_log(CustomerName + " has been removed from customer pool permanently")
	
	var explode_tween = create_tween()
	var shake_steps: int = int(explode_shake_duration / 0.03)
	for i in shake_steps:
		var shake_offset = Vector2(
			randf_range(-explode_shake_intensity, explode_shake_intensity),
			randf_range(-explode_shake_intensity, explode_shake_intensity)
		) / scale
		explode_tween.tween_property(self, "offset", shake_offset, 0.03)
	
	explode_tween.set_parallel(true)
	explode_tween.tween_property(self, "scale", Vector2(1.5, 1.5), explode_fade_duration)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_IN)
	explode_tween.tween_property(self, "modulate:a", 0.0, explode_fade_duration)
	explode_tween.set_parallel(false)
	explode_tween.tween_callback(_on_exploded)


func _on_exploded() -> void:
	offset = Vector2.ZERO
	if customer_names.is_empty():
		DebugManager.debug_log("All customers exploded!")
		modulate.a = 1.0
		scale = original_scale
		hide()
		trigger_game_ending("explode")
		return

	var pause_tween = create_tween()
	pause_tween.tween_interval(0.75)
	pause_tween.tween_callback(new_customer)
	
func trigger_game_ending(ending_type: String) -> void:
	var cauldron = get_node_or_null("/root/Game/WitchCauldron")
	if cauldron:
		cauldron.set_process_input(false)
		cauldron.set_process_unhandled_input(false)
	
	var journal = get_tree().get_first_node_in_group("NotebookMenu")
	if journal:
		journal.visible = false
		
	if walk_sfx:
		walk_sfx.stop()
	
	await get_tree().create_timer(1.2).timeout
	
	# Match dialogue file to ending type
	var dialogue_file_path: String = ""
	if ending_type == "cure":
		dialogue_file_path = "res://Dialogue/Cure Ending.dialogue"
		$"../HighSatisfactionEnding".visible = true
		$"../UI/NotebookMenu".visible = false
		$"../UI/PotionPopup".visible = false
		Globals.customerSatisfaction = 0
	if ending_type == "lack_of_satisfaction":
		dialogue_file_path = "res://Dialogue/Lack of Satisfaction Ending.dialogue"
		$"../LowSatisfactionEnding".visible = true
		$"../UI/NotebookMenu".visible = false
		$"../UI/PotionPopup".visible = false
		Globals.customerSatisfaction = 0
	if ending_type == "explode":
		dialogue_file_path = "res://Dialogue/Explode Ending.dialogue"
		Globals.customerSatisfaction = 0
	
	await get_tree().create_timer(1.0).timeout
	
	if ResourceLoader.exists(dialogue_file_path):
		var dialogue_resource = load(dialogue_file_path)
		DialogueManager.show_dialogue_balloon(dialogue_resource, "start" )
		await DialogueManager.dialogue_ended
	
	var fade_overlay := ColorRect.new()
	fade_overlay.color = Color(0, 0, 0, 0)
	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var canvas_layer := CanvasLayer.new()
	canvas_layer.layer = 999
	canvas_layer.add_child(fade_overlay)
	get_tree().root.add_child(canvas_layer)
	
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "color:a", 1.0, 3.0)
	await fade_tween.finished
	
	await get_tree().create_timer(2.0).timeout
	canvas_layer.queue_free()
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_smoke_animation_finished() -> void:
	SmokeTransition.visible = false
