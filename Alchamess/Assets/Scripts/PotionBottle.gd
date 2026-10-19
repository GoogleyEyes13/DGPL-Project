extends CharacterBody2D
class_name PotionBottle

@export var potionType: String = "Potion1"
@export var potionName: String = "null"
@export var flip_h: bool = false

var FilledSprite: int = 1
var is_grabbed: bool = true
var on_customer: bool = false
var is_filled: bool = false

@onready var PotionBottleSprite: AnimatedSprite2D = $AnimatedSprite2D

signal PotionToCustomer(potion_name: String)
var CurrentHeldPotion: String = "null"


func _ready() -> void:
	global_position = get_global_mouse_position()
	
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
			is_grabbed = false
			if on_customer and is_filled:
				hand_potion_to_customer()
			else:
				queue_free()
				
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed and is_grabbed and on_customer and is_filled:
			hand_potion_to_customer()


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
	if area.get_parent() and area.get_parent().name == "Customer":
		on_customer = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent() and area.get_parent().name == "Customer":
		on_customer = false
