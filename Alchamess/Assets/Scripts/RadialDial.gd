@tool
extends Control
class_name RadialDial

@export var max_count: int = 10:
	set(new_max):
		max_count = max(new_max, 1)
		queue_redraw()

@export var value: int = 0:
	set(new_val):
		var old_val: int = value
		value = clamp(new_val, 0, max_count)
		_displayed_value = float(value)
		_update_label()
		queue_redraw()

# Visual Styling
@export var background_color: Color = Color(0.25, 0.2, 0.15, 0.25)
@export var fill_color: Color = Color(0.85, 0.65, 0.2, 1.0)
@export var border_color: Color = Color(0.18, 0.12, 0.08, 1.0)
@export var ring_thickness: float = 6.0
@export var show_center_text: bool = false

# Internal tracking for smooth animation
var _displayed_value: float = 0.0
var _anim_tween: Tween

@onready var center_label: Label = get_node_or_null("CenterLabel")

func _ready() -> void:
	_displayed_value = float(value)
	_update_label()
	queue_redraw()

func _update_label() -> void:
	if center_label:
		center_label.visible = show_center_text
		center_label.text = "%d" % int(round(_displayed_value))

func set_max_count(new_max: int) -> void:
	max_count = new_max
	_update_label()
	queue_redraw()

## Updates the dial count. If count increased, triggers a smooth fill and slight bounce punch.
func update_count(target_count: int, animate: bool = true) -> void:
	var clamped_target: float = float(clamp(target_count, 0, max_count))
	var is_increase: bool = target_count > value
	value = target_count

	if not animate or not is_inside_tree():
		_displayed_value = clamped_target
		_update_label()
		queue_redraw()
		return

	if _anim_tween and _anim_tween.is_running():
		_anim_tween.kill()

	_anim_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Smoothly fill the arc
	_anim_tween.tween_method(
		func(val: float):
			_displayed_value = val
			_update_label()
			queue_redraw(),
		_displayed_value,
		clamped_target,
		0.4
	)

	# Slight physical punch pop on discovery
	if is_increase:
		pivot_offset = size / 2.0
		_anim_tween.parallel().tween_property(self, "scale", Vector2(1.12, 1.12), 0.12)
		_anim_tween.chain().tween_property(self, "scale", Vector2.ONE, 0.12)

func _draw() -> void:
	var center: Vector2 = size / 2.0
	var outer_radius: float = min(size.x, size.y) / 2.0 - 2.0
	var inner_radius: float = outer_radius - ring_thickness

	if inner_radius <= 0:
		return

	# 1. Background Track (Unfilled Ring)
	draw_arc(center, (outer_radius + inner_radius) / 2.0, 0, TAU, 48, background_color, ring_thickness, true)
	
	# Thin Outer & Inner borders for parchment book aesthetic
	draw_arc(center, outer_radius, 0, TAU, 48, border_color, 1.5, true)
	draw_arc(center, inner_radius, 0, TAU, 48, border_color, 1.5, true)

	# 2. Progress Arc (Starts from top = -PI/2)
	var progress_ratio: float = _displayed_value / float(max_count)
	if progress_ratio > 0.001:
		var start_angle: float = -PI / 2.0
		var sweep_angle: float = start_angle + (TAU * progress_ratio)
		draw_arc(center, (outer_radius + inner_radius) / 2.0, start_angle, sweep_angle, 48, fill_color, ring_thickness, true)
