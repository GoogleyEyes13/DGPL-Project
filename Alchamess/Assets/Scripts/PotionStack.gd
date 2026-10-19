extends Area2D

@export var potion_scene: PackedScene = preload("res://Objects/Potion.tscn")
@export var default_potion_type: String = "Potion1"

@onready var Cauldron = $"../WitchCauldron"
@onready var pickup_sfx: AudioStreamPlayer2D = get_node_or_null("PickupSFX")


func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		spawn_bottle()


func spawn_bottle() -> void:
	if potion_scene == null:
		DebugManager.debug_log("No Potion Scene assigned to PotionStack!")
		return
		
	var new_bottle: PotionBottle = potion_scene.instantiate()
	new_bottle.potionName = Cauldron.LastPotionCreated
	
	get_tree().current_scene.add_child(new_bottle)
	
	# Play bottle pickup sound
	if pickup_sfx:
		pickup_sfx.pitch_scale = randf_range(0.95, 1.05) # Optional subtle pitch variation
		pickup_sfx.play()
