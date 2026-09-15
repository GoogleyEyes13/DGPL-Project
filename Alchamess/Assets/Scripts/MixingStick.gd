extends CharacterBody2D

var is_grabbed := false

var starting_position: Vector2
var grab_mouse_x := 0.0
var grab_stick_x := 0.0

@export var movement_range := 180.0

# Tracks the number of completed side-to-side movements
var mix_count := 0

# Tracks which side was last
var last_side := ""

# The liquid in the cauldron
@onready var WitchCauldronLiquid = $"../WitchCauldron/WitchCauldronLiquid"

# Signal for when the potion is mixed
signal potion_mixed

func _ready():
	starting_position = position


func _process(_delta):
	# Checks if the left mouse button has been released
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_grabbed = false
	
	if is_grabbed:
		var mouse_pos = get_global_mouse_position()
		
		# How far the mouse has moved horizontally since clicking
		var mouse_difference = mouse_pos.x - grab_mouse_x
		
		# Move the stick by the same amount
		var new_x = grab_stick_x + mouse_difference
		
		# Clamp movement to 100 pixels left of starting position
		position.x = clamp(
			new_x,
			starting_position.x - movement_range,
			starting_position.x
		)
		
		# Keep Y unchanged
		position.y = starting_position.y
		
		# make the stick rotate when mixing
		rotation_degrees = (position.x - 970) / 4
		
		# Check if the stick has reached either side
		var left_side = starting_position.x - movement_range
		var right_side = starting_position.x
		
		if position.x <= left_side:
			if last_side != "left":
				last_side = "left"
				mix_count += 1
		
		elif position.x >= right_side:
			if last_side != "right":
				last_side = "right"
				mix_count += 1
		
		# Once three side-to-side movements are made, the potion is mixed
		if mix_count >= 6:
			potion_mixed.emit()
			
			# Reset the count
			mix_count = 0
			last_side = ""


func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_grabbed = true
				
				# Remember where the mouse and stick were when clicked
				grab_mouse_x = get_global_mouse_position().x
				grab_stick_x = position.x
			
			else:
				is_grabbed = false
