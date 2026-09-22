extends AnimatedSprite2D


#region Variables
# The current customer loaded
var CustomerName: String = "Queso"

var start_pos: Vector2
var centre_pos: Vector2
var end_pos: Vector2
var cust_is_ready: bool = false
var original_scale: Vector2
var is_shrunk = false

#Vetical movement
@export var step_bounce_height: float = 8.0
#Horizontal speed(time between each bounce)
@export var step_speed: float = 6.0
#Customer name list (Animation names)
@export var customer_names: Array[String] = ["Queso", "HerbBert", "MrMonicle"]

#Rapid Shaking potion
@export var jitter_intensity: float = 4.0
@export var jitter_step_time: float = 0.05 #time per shake
@export var walk_out_duration: float = 3.5 #total time spent shaking (should generally match bob_out's travel_duration

@export var explode_shake_intensity: float = 12.0
@export var explode_shake_duration: float = 0.5
@export var explode_fade_duration: float = 0.8

# Dictionary for potions and their effects
var PotionEffects: Dictionary = {
	"Normal": 0,
	"Potion of Curing": 0,
	"Potion of Rapid Shaking": 0,
	"Potion of Permanent Smile": 0,
	"Potion of Explode": 0,
	"Potion of Change Language": 0,
	"Potion of Mogging": 0,
	"Potion of Body Swap": 0,
	"Potion of Love": 0,
	"Potion of Enlarge Person": 0,
	"Potion of Shrink Person": 0,
	"Potion Of Baldness": 1,
	"Potion of Head Size Increase": 2,
	"Potion of Head Size Decrease": 3,
	"Potion of Green Skin": 4,
	"Potion of Eye Colour Swap": 5,
	"Potion of Skeleton": 6,
	"Potion of Change Art Styles": 7,
	"Potion of Creature Feature": 8,
	"Potion of Beautification": 9,
	"Potion of Rabies": 10
}

@onready var PotionEffectSprite: AnimatedSprite2D = $"."
@onready var SmokeTransition = $"../Smoke"

# Audio
var walk_sounds: Dictionary = {
	"Queso": preload("res://Assets/Audio/SFX/Walking/quesowalking.wav"),
}
var default_walk_sound: AudioStream = preload("res://Assets/Audio/SFX/Walking/regularwalking.wav")

@onready var walk_sfx: AudioStreamPlayer = $WalkSFX
@onready var smoke_sfx: AudioStreamPlayer = $SmokeSFX
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DebugManager.register_customer(self)
	# Connecting potion given signals
	$"../Potion1".PotionToCustomer.connect(receive_potion)
	$"../Potion1-2".PotionToCustomer.connect(receive_potion)
	$"../Potion2".PotionToCustomer.connect(receive_potion)
	$"../Potion2-2".PotionToCustomer.connect(receive_potion)
	$"../Potion3".PotionToCustomer.connect(receive_potion)
	$"../Potion4".PotionToCustomer.connect(receive_potion)
	$"../Potion5".PotionToCustomer.connect(receive_potion)
	$"../Potion5-2".PotionToCustomer.connect(receive_potion)
	
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


func bob_in() -> void:
	show()
	
	walk_sfx.stream = walk_sounds.get(CustomerName, default_walk_sound)
	walk_sfx.play()
	
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
	walk_sfx.stop()
	global_position.y = centre_pos.y
	DebugManager.debug_log(CustomerName + " is at the counter! Waiting for interaction...") #test
	match CustomerName:
		"Queso":
			var resource = load("res://Dialogue/Queso.dialogue")
			DialogueManager.show_dialogue_balloon(resource)
		"HerbBert":
			var resource = load("res://Dialogue/HerbBert.dialogue")
			DialogueManager.show_dialogue_balloon(resource)
		"MrMonicle":
			var resource = load("res://Dialogue/MrMonicle.dialogue")
			DialogueManager.show_dialogue_balloon(resource)
		_:
			var resource = load("res://Dialogue/Queso.dialogue")
			DialogueManager.show_dialogue_balloon(resource)
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
	DebugManager.debug_log("Potion Received")
	
	if not cust_is_ready:
		return
		
	cust_is_ready = false
	
	if PotionEffects.has(potion_type):
		# Smoke transition effect
		SmokeTransition.visible = true
		SmokeTransition.play()
		smoke_sfx.stream = preload("res://Assets/Audio/SFX/Smoke Puff/smoke puff.mp3")
		smoke_sfx.play()
		
		await get_tree().create_timer(0.3).timeout
		
		frame = PotionEffects[potion_type]
		DebugManager.debug_log("Potion effect on customer: " + potion_type)
		var delay_time: float = 1.0
		
		if potion_type == "Potion of Explode":
			explode_effect()
			return
		elif potion_type == "Potion of Rapid Shaking":
			delay_time = 1.0
			jitter_effect(delay_time + walk_out_duration)
		elif potion_type == "Potion of Creature Feature":
			# Increasing size of creature a lil bit
			scale = Vector2(0.16, 0.16)
		elif potion_type == "Potion of Enlarge Person":
			# Increase size of sprite
			scale = Vector2(0.16, 0.16)
		elif potion_type == "Potion of Shrink Person":
			# Decrease size of sprite
			scale = Vector2(0.07, 0.07)
			position.y += 45
			is_shrunk = true
			
		var delay = create_tween()
		delay.tween_interval(delay_time)
		delay.tween_callback(bob_out)
	else:
		push_warning("Unknown potion type: " + potion_type)


func bob_out() -> void:
	walk_sfx.stream = walk_sounds.get(CustomerName, default_walk_sound)
	walk_sfx.play()
	
	var move_tween = create_tween()
	move_tween.tween_property(self, "global_position:x", end_pos.x, walk_out_duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	move_tween.tween_callback(new_customer)
	
	# Making the customer sit lower if the shrink potion has been used
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
	
	#edge case
	if customer_names.is_empty():
		push_warning("No customer names assigned!")
		return
	
	# Setting customer size to default
	modulate.a = 1.0
	scale = Vector2(0.12, 0.12)

	#Gets the next customer, 
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


func explode_effect() -> void:
	walk_sfx.stop()
	
	# Permanently remove this customer
	customer_names.erase(CustomerName)
	DebugManager.debug_log(CustomerName + " has been removed from the customer pool permanently")
	
	var explode_tween = create_tween()
	
	var shake_steps: int = int(explode_shake_duration / 0.03)
	for i in shake_steps:
		var shake_offset = Vector2(
			randf_range(-explode_shake_intensity, explode_shake_intensity),
			randf_range(-explode_shake_intensity, explode_shake_intensity)
		) / scale
		explode_tween.tween_property(self, "offset", shake_offset, 0.03)
	
	explode_tween.set_parallel(true)
	explode_tween.tween_property(self, "scale", Vector2.ZERO, explode_fade_duration)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
	explode_tween.tween_property(self, "modulate:a", 0.0, explode_fade_duration)
	explode_tween.set_parallel(false)
	
	explode_tween.tween_callback(_on_exploded)

func _on_exploded() -> void:
	offset = Vector2.ZERO
	
	if customer_names.is_empty():
		DebugManager.debug_log("All customers have been exploded! No one left to serve.")
		modulate.a = 1.0
		scale = original_scale
		hide() # Change when there is an ending for killing everyone
		return

	var pause_tween = create_tween()
	pause_tween.tween_interval(0.75)
	pause_tween.tween_callback(new_customer)

func _on_smoke_animation_finished() -> void:
	# Making the smoke animation invisible after its played once
	SmokeTransition.visible = false
