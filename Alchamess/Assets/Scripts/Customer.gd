extends AnimatedSprite2D

# The current customer loaded
var CustomerName: String = "Caseoh"

var start_pos: Vector2
var centre_pos: Vector2
var end_pos: Vector2
var cust_is_ready: bool = false

#Vetical movement
@export var step_bounce_height: float = 8.0
#Horizontal speed(time between each bounce)
@export var step_speed: float = 6.0
#Customer name list (Animation names
@export var customer_names: Array[String] = ["Caseoh", "HerbBert", "Monicle"]

#Rapid Shaking potion
@export var jitter_intensity: float = 4.0
@export var jitter_step_time: float = 0.05 #time per shake
@export var walk_out_duration: float = 3.5 #total time spent shaking (should generally match bob_out's travel_duration


# Dictionary for potions and their effects
var PotionEffects: Dictionary = {
	"Normal": 0,
	"Potion of Curing": 0,
	"Potion of Rapid Shaking": 0,
	"Potion Of Baldness": 1,
	"Potion of Head Size Increase": 2,
	"Potion of Head Size Decrease": 3,
	"Potion of Green Skin": 4,
	"Potion of Eye Colour Swap": 5,
	"Potion of Skeleton": 6,
	"Potion of Change Art Styles": 7
}

@onready var PotionEffectSprite: AnimatedSprite2D = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connecting potion creation signal
	$"../WitchCauldron".potion_created.connect(receive_potion)
	
	var window_size = get_viewport_rect().size
	
	start_pos = Vector2(window_size.x + 200, window_size.y / 2)
	centre_pos = Vector2(window_size.x / 2, window_size.y / 2)
	end_pos = Vector2(-200, window_size.y / 2)

	global_position = start_pos

	animation = CustomerName
	frame = 0
	stop()

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
	cust_is_ready = true

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
	if not cust_is_ready:
		return
		
	cust_is_ready = false
	
	var delay_time: float = 1.0
	
	if PotionEffects.has(potion_type):
		frame = PotionEffects[potion_type]
		print("Potion effect on customer: ", potion_type)
		
		if potion_type == "Potion of Rapid Shaking":
			delay_time = 1.0
			jitter_effect(delay_time + walk_out_duration)   # shake through the whole exit
	else:
		push_warning("Unknown potion type: " + potion_type)
	
	var delay = create_tween()
	delay.tween_interval(delay_time)
	delay.tween_callback(bob_out)

func bob_out() -> void:
	var move_tween = create_tween()
	move_tween.tween_property(self, "global_position:x", end_pos.x, walk_out_duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	move_tween.tween_callback(new_customer)

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
		receive_potion("Potion of Rapid Shaking")

func new_customer() -> void:
	#edge case
	if customer_names.is_empty():
		push_warning("No customer names assigned!")
		return

	#Gets the nexxt customer, 
	var next_name: String = customer_names[randi() % customer_names.size()]
	if customer_names.size() > 1:
		while next_name == CustomerName: 
			next_name = customer_names[randi() % customer_names.size()]
			#Randomises so its never the same character twice in a row

	CustomerName = next_name
	animation = CustomerName
	
	
	#frame = 0 #Reset to default character (CHANGE THIS IF WE WANT TO RETAIN THE CHANGE)
	stop()

	global_position = start_pos
	cust_is_ready = false

	bob_in()
