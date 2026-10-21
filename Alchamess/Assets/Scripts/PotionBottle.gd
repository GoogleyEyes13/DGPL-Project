extends CharacterBody2D
class_name PotionBottle

@export var potionType: String = "Potion1"
@export var potionName: String = "null"
@export var flip_h: bool = false
@export var resting_position: Vector2 = Vector2(1100, 650)

var FilledSprite: int = 1
var is_grabbed: bool = true
var on_customer: bool = false
var on_trash: bool = false
var is_filled: bool = false

@onready var PotionBottleSprite: AnimatedSprite2D = $AnimatedSprite2D

signal PotionToCustomer(potion_name: String)
var CurrentHeldPotion: String = "null"


func _ready() -> void:
	global_position = get_global_mouse_position()
	input_pickable = true
	
	if PotionBottleSprite:
		PotionBottleSprite.flip_h = flip_h
		_apply_bottle_visuals(potionName)


func _apply_bottle_visuals(p_name: String) -> void:
	var info: Dictionary = PotionDatabase.get_potion_info_by_name(p_name)
	var anim: String = info.get("bottle_anim", potionType if potionType != "null" else "Potion1")
	FilledSprite = info.get("bottle_frame", 1)
	
	if PotionBottleSprite:
		PotionBottleSprite.animation = anim
		PotionBottleSprite.frame = 0


func _process(_delta: float) -> void:
	if is_grabbed:
		global_position = get_global_mouse_position()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and is_grabbed:
			_handle_release()
				
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed and is_grabbed and on_customer and is_filled:
			hand_potion_to_customer()


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	# Allow picking the bottle back up if it was resting on the counter
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_grabbed:
			is_grabbed = true


func _handle_release() -> void:
	is_grabbed = false
	
	# 1. Given to customer
	if on_customer and is_filled:
		hand_potion_to_customer()
		return

	# 2. Dropped in trash / sink
	if on_trash:
		dispose_potion()
		return

	# 3. Dropped in empty space: if filled, snap to counter; if empty, free it
	if is_filled:
		snap_to_resting_position()
	else:
		queue_free()


func snap_to_resting_position() -> void:
	var target_pos: Vector2 = resting_position
	
	# Check if a visual marker exists in the scene
	var rest_node = get_tree().get_first_node_in_group("PotionRestPoint")
	if rest_node is Node2D:
		target_pos = rest_node.global_position

	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_pos, 0.25)


func dispose_potion() -> void:
	DebugManager.debug_log("Potion disposed: " + CurrentHeldPotion)
	queue_free()


func fill_bottle(made_potion_name: String) -> void:
	is_filled = true
	CurrentHeldPotion = made_potion_name
	
	_apply_bottle_visuals(made_potion_name)
	
	if PotionBottleSprite:
		PotionBottleSprite.frame = FilledSprite
		
	DebugManager.debug_log("Potion Bottle Filled! Made: " + CurrentHeldPotion)


func hand_potion_to_customer() -> void:
	PotionToCustomer.emit(CurrentHeldPotion)
	
	if DebugManager.current_customer and DebugManager.current_customer.has_method("receive_potion"):
		DebugManager.current_customer.receive_potion(CurrentHeldPotion)
		
	DebugManager.debug_log("Potion effect: " + CurrentHeldPotion + " applied to customer")
	queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	var parent_node = area.get_parent()
	if parent_node:
		if parent_node.name == "Customer":
			on_customer = true
		elif parent_node.name == "TrashBin" or parent_node.name == "Sink" or area.is_in_group("Disposal"):
			on_trash = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	var parent_node = area.get_parent()
	if parent_node:
		if parent_node.name == "Customer":
			on_customer = false
		elif parent_node.name == "TrashBin" or parent_node.name == "Sink" or area.is_in_group("Disposal"):
			on_trash = false
