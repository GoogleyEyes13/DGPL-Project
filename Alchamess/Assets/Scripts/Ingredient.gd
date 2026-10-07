@tool
extends CharacterBody2D
class_name IngredientItem

@export var ingredientType: String = ""

@export_group("Textures")
@export var shelf_texture: Texture2D
@export var dragged_texture: Texture2D

@export_group("Audio")
@export var pickup_sound: AudioStream

@onready var shelf_sprite: Sprite2D = $ShelfSprite
@onready var dragged_sprite: Sprite2D = $DraggedSprite
@onready var pickup_sfx: AudioStreamPlayer = $PickupSFX
@onready var dial: Control = get_node_or_null("IngredientDial")

var is_grabbed: bool = false
var start_position: Vector2


func _ready() -> void:
	start_position = global_position
	
	if shelf_texture:
		shelf_sprite.texture = shelf_texture
	if dragged_texture:
		dragged_sprite.texture = dragged_texture
		
	shelf_sprite.visible = true
	dragged_sprite.visible = false
	
	_ensure_in_ingredients_folder()
	_connect_cauldron_signal()


func _ensure_in_ingredients_folder() -> void:
	var ingredients_folder = get_node_or_null("/root/Game/Ingredients")
	if ingredients_folder and get_parent() != ingredients_folder:
		reparent(ingredients_folder)


func _connect_cauldron_signal() -> void:
	var cauldron = get_node_or_null("/root/Game/WitchCauldron")
	if cauldron and cauldron.has_signal("ingredient_counts_updated"):
		cauldron.ingredient_counts_updated.connect(_on_ingredient_counts_updated)


func _on_ingredient_counts_updated(counts: Dictionary) -> void:
	if counts.has(ingredientType) and dial and dial.has_method("update_count"):
		dial.update_count(counts[ingredientType])


func _process(_delta: float) -> void:
	if is_grabbed:
		global_position = get_global_mouse_position()


func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			pickup()
		else:
			drop()


func pickup() -> void:
	is_grabbed = true
	shelf_sprite.visible = false
	dragged_sprite.visible = true
	
	if pickup_sound:
		pickup_sfx.stream = pickup_sound
		pickup_sfx.play()


func drop() -> void:
	if not is_grabbed:
		return
		
	is_grabbed = false
	shelf_sprite.visible = true
	dragged_sprite.visible = false
	global_position = start_position
