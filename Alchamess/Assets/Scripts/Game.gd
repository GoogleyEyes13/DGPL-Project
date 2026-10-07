extends Node2D

@onready var camera_2d: Camera2D = $Camera2D
@onready var notebook_menu: Control = $UI/NotebookMenu


@export_group("Camera Positions")
@export var start_position: Vector2 = Vector2(953, 407)
@export var target_position: Vector2 = Vector2(960, 540)

@export_group("Camera Zoom")
@export var start_zoom: Vector2 = Vector2(4, 4)
@export var target_zoom: Vector2 = Vector2(1.0, 1.0)
@export var zoom_duration: float = 2.5

func _ready() -> void:
	if notebook_menu:
		notebook_menu.visible = false

	if camera_2d:
		camera_2d.enabled = true
		camera_2d.global_position = start_position
		camera_2d.zoom = start_zoom
		
		var camera_tween = create_tween().set_parallel(true)
		
		camera_tween.tween_property(
			camera_2d,
			"global_position",
			target_position,
			zoom_duration
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
		camera_tween.tween_property(
			camera_2d,
			"zoom",
			target_zoom,
			zoom_duration
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
		camera_tween.chain().tween_callback(reveal_ui)


func reveal_ui() -> void:
	if notebook_menu:
		notebook_menu.visible = true
		
	var customer = get_node_or_null("Customer")
	if customer and customer.has_method("trigger_opening_dialogue"):
		customer.trigger_opening_dialogue()
