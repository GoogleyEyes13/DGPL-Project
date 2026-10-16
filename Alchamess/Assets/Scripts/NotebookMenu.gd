extends Control

#region Variables
# Point this to your book button in the scene
@onready var book_button: TextureButton = $BookButton
@onready var panel: Panel = $NotebookPanel

@onready var ingredient_list_view: VBoxContainer = $NotebookPanel/MarginContainer/IngredientListView
@onready var ingredient_list_container: GridContainer = $NotebookPanel/MarginContainer/IngredientListView/ScrollContainer/IngredientListContainer
@export var ingredient_icons: Array[Texture2D] = []

@onready var potion_list_view: VBoxContainer = $NotebookPanel/MarginContainer/PotionListView
@onready var potion_list_container: VBoxContainer = $NotebookPanel/MarginContainer/PotionListView/ScrollContainer/PotionListContainer
@onready var back_to_ingredients_button: Button = $NotebookPanel/MarginContainer/PotionListView/BackButton

@onready var potion_detail_view: VBoxContainer = $NotebookPanel/MarginContainer/PotionDetailView
@onready var back_to_potions_button: Button = $NotebookPanel/MarginContainer/PotionDetailView/BackButton
@onready var detail_title_label: Label = $NotebookPanel/MarginContainer/PotionDetailView/TitleLabel
@onready var detail_image_1: TextureRect = $NotebookPanel/MarginContainer/PotionDetailView/ImageRow/Image1
@onready var detail_image_2: TextureRect = $NotebookPanel/MarginContainer/PotionDetailView/ImageRow/Image2
@onready var detail_ingredients_label: Label = $NotebookPanel/MarginContainer/PotionDetailView/IngredientsLabel
@onready var detail_notes_field: TextEdit = $NotebookPanel/MarginContainer/PotionDetailView/NotesField

# Hover Tween Settings
@export var hover_scale: Vector2 = Vector2(0.22, 0.22)
@export var tween_duration: float = 0.15
var base_scale: Vector2 = Vector2.ONE
var scale_tween: Tween


var ingredient_names: Array[String] = [
	"ElbowGrease", "OilOfVitriol", "PhoenixFeather",
	"Wormwood", "EyeOfNewt", "Stardust"
]

var ingredient_display_names: Dictionary = {
	"ElbowGrease": "Elbow Grease",
	"OilOfVitriol": "Oil Of Vitriol",
	"PhoenixFeather": "Phoenix Feather",
	"Wormwood": "Wormwood",
	"EyeOfNewt": "Eye Of Newt",
	"Stardust": "Stardust"
}

var current_ingredient: String = ""
var current_potion: String = ""

# Default silhouette / placeholder
var default_before_texture = preload("res://Assets/Sprites/Herb Bert/HerbBertBigHead.png")
var default_after_texture = preload("res://Assets/Sprites/Herb Bert/HerbBertBald.png")

# Audio
@onready var notebook_sfx: AudioStreamPlayer = $NotebookSFX
var sfx_open = preload("res://Assets/Audio/SFX/Notebook/notebook open.wav")
var sfx_close = preload("res://Assets/Audio/SFX/Notebook/notebookclose.wav")
var sfx_forward = preload("res://Assets/Audio/SFX/Notebook/notebookforward.wav")
var sfx_backward = preload("res://Assets/Audio/SFX/Notebook/notebookbackward.wav")

const POTION_SUFFIX_MAP: Dictionary = {
	"Normal": "Normal",
	"Potion of Baldness": "Bald",
	"Potion of Head Size Increase": "BigHead",
	"Potion of Head Size Decrease": "SmallHead",
	"Potion of Eye Colour Swap": "BlueEyes",
	"Potion of Beautification": "Beautification",
	"Potion of Green Skin": "Green",
	"Potion of Mogging": "Mog",
	"Potion of Rabies": "Rabies",
	"Potion of Skeleton": "Skeleton",
	"Potion of Body Swap": "BodySwap",
	"Potion of Change Art Styles": "ArtStyleSwap",
	"Potion of Creature Feature": "TheFeaturedCreature",
	# Add additional potions as their corresponding sprites are completed:
	# "Potion of Permanent Smile": "PermanentSmile",
	# "Potion of Explode": "Explode",
	# "Potion of Change Language": "ChangeLanguage",
	# "Potion of Love": "Love",
	# "Potion of Enlarge Person": "Enlarge",
	# "Potion of Shrink Person": "Shrink",
	# "Potion of Rapid Shaking": "RapidShaking",
	# "Potion of Curing": "Normal"
}
const CHARACTER_FOLDER_ALIASES: Dictionary = {
	"HerbBert": "Herb Bert",
	"Caseoh": "Caseoh",
	"LadyPenelope": "LadyP"
}

#endregion

func _ready() -> void:
	visible = true
	panel.visible = false
	
	# Setup Book Button
	base_scale = book_button.scale
	book_button.pivot_offset = book_button.size / 2.0
	book_button.pressed.connect(_on_book_pressed)
	book_button.mouse_entered.connect(_on_book_hover_enter)
	book_button.mouse_exited.connect(_on_book_hover_exit)
	
	back_to_ingredients_button.pressed.connect(_on_back_to_ingredients_pressed)
	back_to_potions_button.pressed.connect(_on_back_to_potions)
	detail_notes_field.text_changed.connect(_on_notes_changed)
	
	_setup_ingredient_buttons()
	_show_ingredient_list()
	
	potion_list_container.add_theme_constant_override("separation", 10)

#region Hover Animation & Click Handling
func _on_book_hover_enter() -> void:
	_animate_book_scale(hover_scale)

func _on_book_hover_exit() -> void:
	_animate_book_scale(base_scale)

func _animate_book_scale(target: Vector2) -> void:
	if scale_tween and scale_tween.is_running():
		scale_tween.kill()
	scale_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(book_button, "scale", target, tween_duration)

func _on_book_pressed() -> void:
	panel.visible = not panel.visible
	book_button.visible = not panel.visible  # <--- Hides the desk button while viewing the journal
	_play_sfx(sfx_open if panel.visible else sfx_close)
	if panel.visible:
		_show_ingredient_list()
		
func close_journal() -> void:
	panel.visible = false
	book_button.visible = true
	_play_sfx(sfx_close)
#endregion

func _play_sfx(stream: AudioStream) -> void:
	notebook_sfx.stream = stream
	notebook_sfx.play()

func _setup_ingredient_buttons() -> void:
	for ingredient in ingredient_names:
		var button: Button = ingredient_list_container.get_node_or_null("Row_" + ingredient)
		if not button:
			continue
		
		var icon: TextureRect = button.get_node_or_null("VBoxContainer/Icon")
		var label: Label = button.get_node_or_null("VBoxContainer/Label")
		
		if label:
			label.text = ingredient_display_names.get(ingredient, ingredient)
		button.pressed.connect(_on_ingredient_selected.bind(ingredient))
		
		var icon_index = ingredient_names.find(ingredient)
		if icon and icon_index < ingredient_icons.size():
			icon.texture = ingredient_icons[icon_index]

func _on_ingredient_selected(ingredient: String) -> void:
	current_ingredient = ingredient
	_play_sfx(sfx_forward)
	_show_potion_list(ingredient)

func _show_potion_list(ingredient: String) -> void:
	ingredient_list_view.visible = false
	potion_detail_view.visible = false
	potion_list_view.visible = true
	
	for child in potion_list_container.get_children():
		child.queue_free()
	
	var potions: Array = PotionJournal.get_potions_for_ingredient(ingredient)
	
	if potions.is_empty():
		var label := Label.new()
		label.text = "No potions discovered yet using " + ingredient_display_names.get(ingredient, ingredient)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		potion_list_container.add_child(label)
		return
	
	for potion_name in potions:
		var entry := HBoxContainer.new()
		entry.custom_minimum_size = Vector2(0, 56)
		entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		entry.add_theme_constant_override("separation", 12)
		
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(48, 48)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		entry.add_child(icon)
		
		var button := Button.new()
		button.text = potion_name
		button.custom_minimum_size = Vector2(0, 44)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(_on_potion_selected.bind(potion_name))
		entry.add_child(button)
		
		potion_list_container.add_child(entry)

func _show_ingredient_list() -> void:
	ingredient_list_view.visible = true
	potion_list_view.visible = false
	potion_detail_view.visible = false

func _on_back_to_ingredients_pressed() -> void:
	_play_sfx(sfx_backward)
	_show_ingredient_list()

func _on_back_to_potions() -> void:
	_play_sfx(sfx_backward)
	_show_potion_list(current_ingredient)

func _on_potion_selected(potion_name: String) -> void:
	current_potion = potion_name
	_play_sfx(sfx_forward)
	potion_list_view.visible = false
	potion_detail_view.visible = true
	
	detail_title_label.text = potion_name
	
	# Ingredients list formatting
	var ingredients: Array = PotionJournal.get_ingredients_for_potion(potion_name)
	var formatted_ingredients: Array = []
	for ing in ingredients:
		formatted_ingredients.append("• " + ingredient_display_names.get(ing, ing))
	detail_ingredients_label.text = "Ingredients:\n" + "\n".join(formatted_ingredients)
	
	# Fetch customer recorded in PotionJournal
	var customer_name: String = PotionJournal.get_potion_customer(potion_name)
	var portraits: Dictionary = _get_customer_portraits(customer_name, potion_name)
	
	detail_image_1.texture = portraits["before"]
	detail_image_2.texture = portraits["after"]
	
	# Always ensure both slots remain visible
	detail_image_1.visible = true
	detail_image_2.visible = true
	
	detail_notes_field.text = PotionJournal.get_note(potion_name)

func _on_notes_changed() -> void:
	if current_potion != "":
		PotionJournal.set_note(current_potion, detail_notes_field.text)

func _unhandled_input(event: InputEvent) -> void:
	if detail_notes_field.has_focus():
		return
		
	if event.is_action_pressed("toggle_journal"):
		_on_book_pressed()

func _get_customer_portraits(customer_name: String, potion_name: String) -> Dictionary:
	# Default to HerbBert for debug testing if no customer has been recorded yet
	var char_name: String = customer_name
	if char_name.is_empty():
		char_name = "HerbBert"

	var folder_name: String = CHARACTER_FOLDER_ALIASES.get(char_name, char_name)
	var suffix: String = POTION_SUFFIX_MAP.get(potion_name, "Normal")

	# Target path: res://Assets/Sprites/(customer name)/(customer name)(suffix).png
	var base_folder: String = "res://Assets/Sprites/" + folder_name + "/"
	var before_path: String = base_folder + char_name + "Normal.png"
	var after_path: String = base_folder + char_name + suffix + ".png"

	var before_tex: Texture2D = null
	var after_tex: Texture2D = null

	# Load 'before' portrait (checks for Normal, then falls back to default)
	if ResourceLoader.exists(before_path):
		before_tex = load(before_path)
	else:
		before_tex = default_before_texture

	# Load 'after' portrait for the specific potion effect
	if ResourceLoader.exists(after_path):
		after_tex = load(after_path)
	else:
		print("Sprite not found at: ", after_path) # Helps identify missing art or naming mismatches
		after_tex = default_after_texture

	return {
		"before": before_tex,
		"after": after_tex
	}
