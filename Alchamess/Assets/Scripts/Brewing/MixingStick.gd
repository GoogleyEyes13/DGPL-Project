extends CharacterBody2D

var is_grabbed := false
var base_scale: Vector2 = Vector2.ONE
var resting_position := Vector2(1059.0, 733.0)

# Exact offset from WitchCauldron to the liquid center
@export var liquid_local_offset := Vector2(-3.334, -400.0)

# Oval radius for the circular stir motion
@export var orbit_radius_x := 115.0
@export var orbit_radius_y := 45.0
@export var max_tilt_deg := 16.0

# Stirring progress tracking
var liquid_global_center: Vector2
var previous_angle: float = 0.0
var total_angular_stir: float = 0.0
const REQUIRED_REVOLUTIONS := 4.0

var mix_count := 0
var allow_mixing := false

# Node references
@onready var Cauldron = $"../WitchCauldron"
@onready var WitchCauldronLiquid = $"../WitchCauldron/WitchCauldronLiquid"

var stir_sounds: Array[AudioStream] = [
	preload("res://Assets/Audio/SFX/Stirring Sounds/stirring1.wav"),
	preload("res://Assets/Audio/SFX/Stirring Sounds/stirring2.wav"),
	preload("res://Assets/Audio/SFX/Stirring Sounds/stirring3.wav"),
]
@onready var stir_sfx: AudioStreamPlayer = $StirSFX

signal potion_mixed

func _ready() -> void:
	base_scale = scale
	resting_position = position # Preserves your exact (1059, 733) placement
	_calculate_liquid_center()
	WitchCauldronLiquid.self_modulate = Color.SKY_BLUE


func _calculate_liquid_center() -> void:
	if Cauldron:
		liquid_global_center = Cauldron.global_position + (liquid_local_offset * Cauldron.global_scale)
	else:
		liquid_global_center = global_position


func _process(delta: float) -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_grabbed = false

	if is_grabbed:
		var mouse_pos = get_global_mouse_position()
		var offset = mouse_pos - liquid_global_center
		
		# Compute angle relative to the liquid's center point
		var current_angle = atan2(offset.y, offset.x)
		
		# Constrain movement to the liquid bowl's oval perimeter
		var norm_x = offset.x / max(orbit_radius_x, 1.0)
		var norm_y = offset.y / max(orbit_radius_y, 1.0)
		var dist = sqrt(norm_x * norm_x + norm_y * norm_y)
		var clamped_dist = clamp(dist, 0.25, 1.0)
		
		var target_global = liquid_global_center + Vector2(
			cos(current_angle) * orbit_radius_x * clamped_dist,
			sin(current_angle) * orbit_radius_y * clamped_dist
		)
		
		# Fluid stirring interpolation
		global_position = global_position.lerp(target_global, 18.0 * delta)
		
		# Stirring tilt angled toward liquid center
		var horizontal_displacement = global_position.x - liquid_global_center.x
		var tilt_target = (horizontal_displacement / orbit_radius_x) * max_tilt_deg
		rotation_degrees = lerp(rotation_degrees, tilt_target, 12.0 * delta)
		scale = base_scale
		
		# Track angular revolutions
		if allow_mixing:
			var angle_delta = wrapf(current_angle - previous_angle, -PI, PI)
			if abs(angle_delta) > 0.02 and abs(angle_delta) < 1.0:
				total_angular_stir += abs(angle_delta)
				
				if total_angular_stir >= (mix_count + 1) * (PI * 0.8):
					mix_count += 1
					_play_stir_sound()
					change_liquid_colour()
				
				if total_angular_stir >= REQUIRED_REVOLUTIONS * TAU:
					potion_mixed.emit()
					allow_mixing = false
					DebugManager.debug_log("Potion fully stirred!")

		previous_angle = current_angle
	else:
		# Return smoothly to resting spot (1059, 733) when released
		position = position.lerp(resting_position, 10.0 * delta)
		rotation_degrees = lerp(rotation_degrees, 0.0, 10.0 * delta)
		scale = base_scale


func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_grabbed = true
			_calculate_liquid_center()
			var offset = get_global_mouse_position() - liquid_global_center
			previous_angle = atan2(offset.y, offset.x)
		else:
			is_grabbed = false


func start_mixing() -> void:
	allow_mixing = true
	total_angular_stir = 0.0
	mix_count = 0


func _play_stir_sound() -> void:
	stir_sfx.pitch_scale = randf_range(0.92, 1.08)
	stir_sfx.stream = stir_sounds[randi() % stir_sounds.size()]
	stir_sfx.play()


func change_liquid_colour() -> void:
	var target_colour = Color("#99855D")
	var progress = clamp(total_angular_stir / (REQUIRED_REVOLUTIONS * TAU), 0.0, 1.0)
	
	match Cauldron.LastPotionCreated:
		"Potion of Curing", "Potion of Enlarge Person", "Potion of Green Skin", \
		"Potion of Change Art Styles", "Potion of Mogging":
			target_colour = Color("#99855D")
		"Potion of Rapid Shaking", "Potion of Permanent Smile", "Potion of Shrink Person", \
		"Potion of Baldness", "Potion of Creature Feature":
			target_colour = Color("#964D27")
		"Potion of Beautification", "Potion of Explode", "Potion of Body Swap", \
		"Potion of Head Size Increase", "Potion of Eye Colour Swap":
			target_colour = Color("#AD3922")
		"Potion of Head Size Decrease", "Potion of Skeleton", "Potion of Rabies", \
		"Potion of Change Language", "Potion of Love":
			target_colour = Color("#c38840")
	
	WitchCauldronLiquid.self_modulate = Color.SKY_BLUE.lerp(target_colour, progress)


func reset_liquid_colour() -> void:
	WitchCauldronLiquid.self_modulate = Color.SKY_BLUE
	total_angular_stir = 0.0
	mix_count = 0
