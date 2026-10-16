extends Control

#region Node References
@onready var book_button: TextureButton = $BookButton
@onready var panel: Control = $NotebookPanel
@onready var close_button: BaseButton = $NotebookPanel.get_node_or_null("CloseButton")

# Left Page (Ingredients)
@onready var ingredient_grid: GridContainer = $NotebookPanel/MarginContainer/BookSpread/LeftPage/ScrollContainer/IngredientGrid
@export var ingredient_icons: Array[Texture2D] = []

# Right Page (Ingredient Showcase & Potion List)
@onready var right_page: Control = $NotebookPanel/MarginContainer/BookSpread/RightPage
@onready var potion_list_view: Control = right_page.get_node_or_null("PotionListView")

@onready var potion_list_header: Label = (
	right_page.get_node_or_null("PotionListView/ListHeader") 
	if right_page.has_node("PotionListView/ListHeader") 
	else right_page.get_node_or_null("ListHeader")
)

@onready var big_ingredient_icon: TextureRect = (
	right_page.get_node_or_null("PotionListView/FeaturedIngredientsBox/BigIngredientIcon")
	if right_page.has_node("PotionListView/FeaturedIngredientsBox/BigIngredientIcon")
	else right_page.get_node_or_null("FeaturedIngredientsBox/BigIngredientIcon")
)

@onready var ingredient_flavor_text: Label = (
	right_page.get_node_or_null("PotionListView/FeaturedIngredientsBox/IngredientFlavorText")
	if right_page.has_node("PotionListView/FeaturedIngredientsBox/IngredientFlavorText")
	else right_page.get_node_or_null("FeaturedIngredientsBox/IngredientFlavorText")
)

@onready var potion_list_container: GridContainer = (
	right_page.get_node_or_null("PotionListView/ScrollContainer/PotionListContainer")
	if right_page.has_node("PotionListView/ScrollContainer/PotionListContainer")
	else right_page.get_node_or_null("ScrollContainer/PotionListContainer")
)

# Radial Dial Nodes
@onready var notebook_dial: RadialDial = (
	right_page.get_node_or_null("PotionListView/DialContainer/NotebookRadialDial")
	if right_page.has_node("PotionListView/DialContainer/NotebookRadialDial")
	else right_page.get_node_or_null("NotebookRadialDial")
)
@onready var dial_progress_label: Label = (
	right_page.get_node_or_null("PotionListView/DialContainer/ProgressLabel")
	if right_page.has_node("PotionListView/DialContainer/ProgressLabel")
	else right_page.get_node_or_null("ProgressLabel")
)

# Right Page (Potion Detail View)
@onready var potion_detail_view: Control = right_page.get_node_or_null("PotionDetailView")
@onready var back_to_potions_button: Button = right_page.get_node_or_null("PotionDetailView/DetailTopBar/BackToPotionsButton")
@onready var detail_title_label: Label = right_page.get_node_or_null("PotionDetailView/DetailTopBar/DetailTitleLabel")
@onready var detail_image_1: TextureRect = right_page.get_node_or_null("PotionDetailView/ImageRow/Image1")
@onready var detail_image_2: TextureRect = right_page.get_node_or_null("PotionDetailView/ImageRow/Image2")
@onready var detail_ingredients_label: Label = right_page.get_node_or_null("PotionDetailView/DetailIngredientsLabel")
@onready var detail_notes_field: TextEdit = right_page.get_node_or_null("PotionDetailView/DetailNotesField")

# Hover Tween Settings
@export var hover_scale: Vector2 = Vector2(0.22, 0.22)
@export var tween_duration: float = 0.15
var base_scale: Vector2 = Vector2.ONE
var scale_tween: Tween

var ingredient_names: Array[String] = [
	"ElbowGrease", "OilOfVitriol", "PhoenixFeather",
	"Wormwood", "EyeOfNewt", "Stardust"
]

var ingredient_descriptions: Dictionary = {
	"ElbowGrease": "Pure, condensed physical labor. Clouded and dense.",
	"EyeOfNewt": "Pickled amphibian oculars. Known to alter vision and forms.",
	"OilOfVitriol": "Corrosive and volatile. Strips away extraneous features.",
	"PhoenixFeather": "Radiates eternal warmth. Essential for restorative draughts.",
	"Stardust": "Glinting cosmic residue. Unlocks strange celestial mutations.",
	"Wormwood": "Bitter perennial herb. Calms nerves and fixes stubborn mixtures."
}

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

const INGREDIENT_ICON_BASE_PATH: String = "res://Assets/Ingredients/%s.png"

var default_before_texture = preload("res://Assets/Sprites/Herb Bert/HerbBertBigHead.png")
var default_after_texture = preload("res://Assets/Sprites/Herb Bert/HerbBertBald.png")

# Audio
@onready var notebook_sfx: AudioStreamPlayer = get_node_or_null("NotebookSFX")
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
}

const CHARACTER_FOLDER_ALIASES: Dictionary = {
	"HerbBert": "Herb Bert",
	"Caseoh": "Caseoh"
}
#endregion

func _ready() -> void:
	visible = true
	panel.visible = false
	book_button.visible = true
	
	base_scale = book_button.scale
	book_button.pivot_offset = book_button.size / 2.0
	book_button.pressed.connect(_on_book_pressed)
	book_button.mouse_entered.connect(_on_book_hover_enter)
	book_button.mouse_exited.connect(_on_book_hover_exit)
	
	if close_button:
		close_button.pressed.connect(close_journal)
	
	if back_to_potions_button:
		back_to_potions_button.pressed.connect(_on_back_to_potions_pressed)
		
	if detail_notes_field:
		detail_notes_field.text_changed.connect(_on_notes_changed)
	
	_setup_ingredient_buttons()
	if potion_list_container:
		potion_list_container.add_theme_constant_override("separation", 8)

#region Open / Close / Hover
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
	if panel.visible:
		close_journal()
	else:
		open_journal()

func open_journal() -> void:
	panel.visible = true
	book_button.visible = false
	_play_sfx(sfx_open)
	
	if current_ingredient.is_empty():
		_on_ingredient_selected(ingredient_names[0])
	else:
		_show_potion_list(current_ingredient)

func close_journal() -> void:
	panel.visible = false
	book_button.visible = true
	_play_sfx(sfx_close)
#endregion

func _play_sfx(stream: AudioStream) -> void:
	if notebook_sfx and stream:
		notebook_sfx.stream = stream
		notebook_sfx.play()

func _setup_ingredient_buttons() -> void:
	if not ingredient_grid:
		return
		
	for ingredient in ingredient_names:
		var button: Button = ingredient_grid.get_node_or_null("Row_" + ingredient)
		if not button:
			continue
		
		var icon: TextureRect = button.get_node_or_null("VBoxContainer/Icon")
		var label: Label = button.get_node_or_null("VBoxContainer/Label")
		
		if label:
			label.text = ingredient_display_names.get(ingredient, ingredient)
		
		if icon:
			var icon_path = INGREDIENT_ICON_BASE_PATH % ingredient
			if ResourceLoader.exists(icon_path):
				icon.texture = load(icon_path)
			else:
				push_warning("Ingredient icon missing at: " + icon_path)
		
		if not button.pressed.is_connected(_on_ingredient_selected):
			button.pressed.connect(_on_ingredient_selected.bind(ingredient))

func _on_ingredient_selected(ingredient: String) -> void:
	current_ingredient = ingredient
	_play_sfx(sfx_forward)
	_show_potion_list(ingredient)

func _show_potion_list(ingredient: String) -> void:
	if potion_detail_view:
		potion_detail_view.visible = false
	if potion_list_view:
		potion_list_view.visible = true
	
	if potion_list_header:
		potion_list_header.text = ingredient_display_names.get(ingredient, ingredient) + " Recipes"
	
	# Load featured reagent icon & lore text
	var icon_path = INGREDIENT_ICON_BASE_PATH % ingredient
	if big_ingredient_icon and ResourceLoader.exists(icon_path):
		big_ingredient_icon.texture = load(icon_path)
		
	if ingredient_flavor_text:
		ingredient_flavor_text.text = ingredient_descriptions.get(ingredient, "")
	
	# Clear old list buttons
	if potion_list_container:
		for child in potion_list_container.get_children():
			child.queue_free()
	
	# Fetch discovered count and total possible recipes for this ingredient
	var unlocked_potions: Array = PotionJournal.get_potions_for_ingredient(ingredient)
	var total_potions_for_ingredient: int = PotionJournal.get_total_count_for_ingredient(ingredient)

	# If the database has 10 potions per ingredient but none are loaded yet, fall back gracefully
	if total_potions_for_ingredient == 0:
		total_potions_for_ingredient = 10

	# Update the Radial Dial & Label
	if notebook_dial:
		notebook_dial.set_max_count(total_potions_for_ingredient)
		notebook_dial.update_count(unlocked_potions.size(), true)
		
	if dial_progress_label:
		dial_progress_label.text = "Discovered: %d / %d" % [unlocked_potions.size(), total_potions_for_ingredient]
		
	# Populate buttons
	if unlocked_potions.is_empty():
		var label := Label.new()
		label.text = "No potions discovered yet with this ingredient."
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if potion_list_container:
			potion_list_container.add_child(label)
		return
	
	for potion_name in unlocked_potions:
		var button := Button.new()
		button.text = potion_name
		button.custom_minimum_size = Vector2(0, 44)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_potion_selected.bind(potion_name))
		if potion_list_container:
			potion_list_container.add_child(button)

func _on_back_to_potions_pressed() -> void:
	_play_sfx(sfx_backward)
	if potion_detail_view:
		potion_detail_view.visible = false
	if potion_list_view:
		potion_list_view.visible = true

func _on_potion_selected(potion_name: String) -> void:
	current_potion = potion_name
	_play_sfx(sfx_forward)
	
	if potion_list_view:
		potion_list_view.visible = false
	if potion_detail_view:
		potion_detail_view.visible = true
	
	if detail_title_label:
		detail_title_label.text = potion_name
	
	var ingredients: Array = PotionJournal.get_ingredients_for_potion(potion_name)
	var formatted_ingredients: Array = []
	for ing in ingredients:
		formatted_ingredients.append("• " + ingredient_display_names.get(ing, ing))
		
	if detail_ingredients_label:
		detail_ingredients_label.text = "\n".join(formatted_ingredients)
	
	var customer_name: String = PotionJournal.get_potion_customer(potion_name)
	var portraits: Dictionary = _get_customer_portraits(customer_name, potion_name)
	
	if detail_image_1:
		detail_image_1.texture = portraits["before"]
	if detail_image_2:
		detail_image_2.texture = portraits["after"]
	
	if detail_notes_field:
		detail_notes_field.text = PotionJournal.get_note(potion_name)

func _get_customer_portraits(customer_name: String, potion_name: String) -> Dictionary:
	var char_name: String = customer_name
	if char_name.is_empty():
		char_name = "HerbBert"

	var folder_name: String = CHARACTER_FOLDER_ALIASES.get(char_name, char_name)
	var suffix: String = POTION_SUFFIX_MAP.get(potion_name, "Normal")

	var base_folder: String = "res://Assets/Sprites/" + folder_name + "/"
	var before_path: String = base_folder + char_name + "Normal.png"
	var after_path: String = base_folder + char_name + suffix + ".png"

	var before_tex: Texture2D = null
	var after_tex: Texture2D = null

	if ResourceLoader.exists(before_path):
		before_tex = load(before_path)
	else:
		before_tex = default_before_texture

	if ResourceLoader.exists(after_path):
		after_tex = load(after_path)
	else:
		after_tex = default_after_texture

	return {
		"before": before_tex,
		"after": after_tex
	}

func _on_notes_changed() -> void:
	if current_potion != "" and detail_notes_field:
		PotionJournal.set_note(current_potion, detail_notes_field.text)

func _unhandled_input(event: InputEvent) -> void:
	if detail_notes_field and detail_notes_field.has_focus():
		return
	if event.is_action_pressed("toggle_journal"):
		_on_book_pressed()
