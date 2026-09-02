extends AnimatedSprite2D

# The current customer loaded
var CustomerName = "Caseoh"

var start_pos: Vector2
var centre_pos: Vector2
var end_pos: Vector2
var cust_is_ready: bool = false

#Vetical movement
@export var step_bounce_height: float = 8.0
#Horizontal speed(time between each bounce)
@export var step_speed: float = 6.0

# Dictionary for potions and their effects
var PotionEffects: Dictionary = {
	"Normal": 0,
	"Potion Of Baldness": 1,
	"Potion of Head Size Increase": 2,
	"Potion of Head Size Decrease": 3,
	"Potion of Green Skin": 4,
	"Potion of Eye Colour Swap": 5,
	"Potion of Mogging": 0,
	"Potion of Beautification": 0,
	"Potion of Rapid Shaking": 0,
	"Potion of Permanent Smile": 0
}

@onready var PotionEffectSprite: AnimatedSprite2D = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connecting potion creation signal
	$"../WitchCauldron".potion_created.connect(_apply_potion_effect)
	
	var window_size = get_viewport_rect().size
	
	start_pos = Vector2(window_size.x + 200, window_size.y / 2)
	centre_pos = Vector2(window_size.x / 2, window_size.y / 2)
	end_pos = Vector2(-200, window_size.y / 2)

	global_position = start_pos
	hide()
	
	bob_in()

func bob_in() -> void:
	show()
	#Time to reach the middle of the screen
	var travel_duration: float = 4.5 
	
	#Main horizontal movement
	var move_tween = create_tween()
	move_tween.tween_property(self, "global_position:x", centre_pos.x, travel_duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	move_tween.tween_callback(on_arrival)
	
	#Stepping loop
	var march_tween = create_tween().set_loops()
	march_tween.tween_property(self, "global_position:y", centre_pos.y - step_bounce_height, 1.0 / step_speed)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	march_tween.tween_property(self, "global_position:y", centre_pos.y, 1.0 / step_speed)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	
	move_tween.tween_callback(march_tween.kill)

func on_arrival() -> void:
	global_position.y = centre_pos.y
	print("Customer is at the counter! Waiting for interaction...") #test
	match CustomerName:
		"Caseoh":
			var resource = load("res://dialogue/testDialogue.dialogue")
			DialogueManager.show_dialogue_balloon(resource)
	cust_is_ready = true

func receive_potion(potion_type: String) -> void:
	if not cust_is_ready:
		return
		
	cust_is_ready = false
	
	#Animation or frame change here
	
	var delay = create_tween()
	delay.tween_interval(1.0)
	delay.tween_callback(bob_out)

func bob_out() -> void:
	var travel_duration: float = 3.5
	
	#Exit
	var move_tween = create_tween()
	move_tween.tween_property(self, "global_position:x", end_pos.x, travel_duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	move_tween.tween_callback(queue_free)
	
	#Movement loop while leaving
	var march_tween = create_tween().set_loops()
	march_tween.tween_property(self, "global_position:y", centre_pos.y - step_bounce_height, 1.0 / step_speed)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	march_tween.tween_property(self, "global_position:y", centre_pos.y, 1.0 / step_speed)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
		
	move_tween.tween_callback(march_tween.kill)

#For testing purposes
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		print("Space pressed: Giving potion to customer!")
		receive_potion("Green Head")

func new_customer() -> void:
	pass

# Applying potion effects to the customer
func _apply_potion_effect(Potion):
	PotionEffectSprite.animation = CustomerName
	
	if PotionEffects.has(Potion):
		PotionEffectSprite.frame = PotionEffects[Potion]
		print("Potion effect on customer: ", Potion)
