@tool
extends CharacterBody2D
class_name IngredientItem

# Preserved both so WitchCauldron and PotionJournal find the exact key they expect
@export var ingredientType: String = ""
@export var ingredient_name: String = "":
	set(val):
		ingredient_name = val
		if ingredientType.is_empty():
			ingredientType = val

@export_group("Textures")
@export var shelf_texture: Texture2D
@export var dragged_texture: Texture2D

@export_group("Audio")
@export var pickup_sound: AudioStream

@onready var dial: RadialDial = get_node_or_null("RadialDial")
@onready var shelf_sprite: Sprite2D = $ShelfSprite
@onready var dragged_sprite: Sprite2D = $DraggedSprite
@onready var pickup_sfx: AudioStreamPlayer = $PickupSFX

var is_grabbed: bool = false
var start_position: Vector2


func _ready() -> void:
	# Synchronize naming if only one was set in the inspector
	if ingredient_name.is_empty() and not ingredientType.is_empty():
		ingredient_name = ingredientType
	elif ingredientType.is_empty() and not ingredient_name.is_empty():
		ingredientType = ingredient_name

	if shelf_texture:
		shelf_sprite.texture = shelf_texture
	if dragged_texture:
		dragged_sprite.texture = dragged_texture
		
	shelf_sprite.visible = true
	dragged_sprite.visible = false

	if Engine.is_editor_hint():
		return

	start_position = global_position

	# Hook up dial to PotionJournal discovery updates
	if dial and not ingredient_name.is_empty():
		refresh_dial(false)
		if is_instance_valid(PotionJournal):
			PotionJournal.journal_updated.connect(func(): refresh_dial(true))
	
	_ensure_in_ingredients_folder()


func refresh_dial(animate: bool = true) -> void:
	if not dial or ingredient_name.is_empty() or not is_instance_valid(PotionJournal):
		return
		
	var clean_name = ingredient_name.strip_edges()
	var total: int = PotionJournal.get_total_count_for_ingredient(clean_name)
	var discovered: int = PotionJournal.get_discovered_count_for_ingredient(clean_name)
	
	dial.set_max_count(total if total > 0 else 5)
	dial.update_count(discovered, animate)


func _ensure_in_ingredients_folder() -> void:
	var ingredients_folder = get_node_or_null("/root/Game/Ingredients")
	if ingredients_folder and get_parent() != ingredients_folder:
		reparent(ingredients_folder)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	if is_grabbed:
		global_position = get_global_mouse_position()


func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if Engine.is_editor_hint():
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			pickup()
		else:
			drop()


func pickup() -> void:
	is_grabbed = true
	shelf_sprite.visible = false
	dragged_sprite.visible = true
	
	if pickup_sound and pickup_sfx:
		pickup_sfx.stream = pickup_sound
		pickup_sfx.play()


func drop() -> void:
	if not is_grabbed:
		return
		
	is_grabbed = false
	
	# Check if dropped onto the Cauldron before snapping back
	var cauldron = get_node_or_null("/root/Game/WitchCauldron")
	if cauldron:
		if cauldron.has_method("add_ingredient"):
			cauldron.add_ingredient(ingredientType)
		elif cauldron.has_method("receive_ingredient"):
			cauldron.receive_ingredient(self)

	shelf_sprite.visible = true
	dragged_sprite.visible = false
	global_position = start_position
