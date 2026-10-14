extends CharacterBody2D
class_name PotionBottle

@export var potionType: String = "Potion1"
@export var potionName: String = "null"
@onready var FilledSprite = "1"
@export var flip_h: bool = false

var is_grabbed: bool = true
var on_customer: bool = false
var is_filled: bool = false

@onready var PotionBottleSprite: AnimatedSprite2D = $AnimatedSprite2D

signal PotionToCustomer(potion_name: String)
var CurrentHeldPotion: String = "null"


func _ready() -> void:
	global_position = get_global_mouse_position()
	
	if potionType != "null" and PotionBottleSprite:
		PotionBottleSprite.animation = potionType
		PotionBottleSprite.flip_h = flip_h
		PotionBottleSprite.frame = 0 # Start empty
	
	match potionName:
		"Potion of Curing":
			PotionBottleSprite.animation = "Potion3"
			PotionBottleSprite.frame = 0
			FilledSprite = 1
		"Potion of Rapid Shaking":
			PotionBottleSprite.animation = "Potion1"
			PotionBottleSprite.frame = 0
			FilledSprite = 2
		"Potion of Permanent Smile":
			PotionBottleSprite.animation = "Potion3"
			PotionBottleSprite.frame = 0
			FilledSprite = 2
		"Potion of Explode":
			PotionBottleSprite.animation = "Potion2"
			PotionBottleSprite.frame = 0
			FilledSprite = 3
		"Potion of Change Language":
			PotionBottleSprite.animation = "Potion2"
			PotionBottleSprite.frame = 0
			FilledSprite = 4
		"Potion of Body Swap":
			PotionBottleSprite.animation = "Potion3"
			PotionBottleSprite.frame = 0
			FilledSprite = 3
		"Potion of Love": 
			PotionBottleSprite.animation = "Potion3"
			PotionBottleSprite.frame = 0
			FilledSprite = 4
		"Potion of Enlarge Person":
			PotionBottleSprite.animation = "Potion2"
			PotionBottleSprite.frame = 0
			FilledSprite = 1
		"Potion of Shrink Person":
			PotionBottleSprite.animation = "Potion2"
			PotionBottleSprite.frame = 0
			FilledSprite = 2
		"Potion of Baldness": 
			PotionBottleSprite.animation = "Potion4"
			PotionBottleSprite.frame = 0
			FilledSprite = 2
		"Potion of Head Size Increase": 
			PotionBottleSprite.animation = "Potion1"
			PotionBottleSprite.frame = 0
			FilledSprite = 3
		"Potion of Head Size Decrease": 
			PotionBottleSprite.animation = "Potion1"
			PotionBottleSprite.frame = 0
			FilledSprite = 4
		"Potion of Green Skin": 
			PotionBottleSprite.animation = "Potion4"
			PotionBottleSprite.frame = 0
			FilledSprite = 1
		"Potion of Eye Colour Swap": 
			PotionBottleSprite.animation = "Potion4"
			PotionBottleSprite.frame = 0
			FilledSprite = 3
		"Potion of Skeleton": 
			PotionBottleSprite.animation = "Potion4"
			PotionBottleSprite.frame = 0
			FilledSprite = 4
		"Potion of Change Art Styles": 
			PotionBottleSprite.animation = "Potion5"
			PotionBottleSprite.frame = 0
			FilledSprite = 1
		"Potion of Creature Feature": 
			PotionBottleSprite.animation = "Potion5"
			PotionBottleSprite.frame = 0
			FilledSprite = 2
		"Potion of Beautification": 
			PotionBottleSprite.animation = "Potion5"
			PotionBottleSprite.frame = 0
			FilledSprite = 3
		"Potion of Rabies": 
			PotionBottleSprite.animation = "Potion5"
			PotionBottleSprite.frame = 0
			FilledSprite = 4
		"Potion of Mogging":
			PotionBottleSprite.animation = "Potion1"
			PotionBottleSprite.frame = 0
			FilledSprite = 1
		_:
			PotionBottleSprite.animation = "Potion1"
			PotionBottleSprite.frame = 0
			FilledSprite = 1


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
	
	# Showing filled frame
	PotionBottleSprite.frame = FilledSprite
		
	DebugManager.debug_log("Potion Bottle Filled! Made: " + CurrentHeldPotion)


func hand_potion_to_customer() -> void:
	PotionToCustomer.emit(CurrentHeldPotion)
	
	if DebugManager.current_customer and DebugManager.current_customer.has_method("receive_potion"):
		DebugManager.current_customer.receive_potion(CurrentHeldPotion)
		
	DebugManager.debug_log("Potion effect: " + CurrentHeldPotion + " applied to customer")
	queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().name == "Customer":
		on_customer = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent().name == "Customer":
		on_customer = false
