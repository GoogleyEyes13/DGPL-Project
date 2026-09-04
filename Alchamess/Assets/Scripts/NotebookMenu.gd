extends Control


#region Variables
@onready var tab_button: Button = $NotebookTab
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
#endregion

func _ready() -> void:
	tab_button.pressed.connect(_on_tab_pressed)
	back_to_ingredients_button.pressed.connect(_show_ingredient_list)
	back_to_potions_button.pressed.connect(_on_back_to_potions)
	detail_notes_field.text_changed.connect(_on_notes_changed)
	
	panel.visible = false
	_setup_ingredient_buttons()
	_show_ingredient_list()
	
	potion_list_container.add_theme_constant_override("separation", 10)

func _setup_ingredient_buttons() -> void:
	for ingredient in ingredient_names:
		var button: Button = ingredient_list_container.get_node("Row_" + ingredient)
		var icon: TextureRect = button.get_node("VBoxContainer/Icon")
		var label: Label = button.get_node("VBoxContainer/Label")
		
		label.text = ingredient_display_names.get(ingredient, ingredient)
		button.pressed.connect(_on_ingredient_selected.bind(ingredient))
		
		var icon_index = ingredient_names.find(ingredient)
		if icon_index < ingredient_icons.size():
			icon.texture = ingredient_icons[icon_index]
			
func _on_tab_pressed() -> void:
	print("Tab clicked, panel visible: ", panel.visible)
	panel.visible = not panel.visible
	if panel.visible:
		_show_ingredient_list()

func _on_ingredient_selected(ingredient: String) -> void:
	current_ingredient = ingredient
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
		label.text = "No potions discovered yet using " + ingredient
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
		# icon.texture = load("res://path/to/%s_icon.png" % potion_name)  # plug in art later
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

func _on_back_to_potions() -> void:
	_show_potion_list(current_ingredient)

func _on_potion_selected(potion_name: String) -> void:
	current_potion = potion_name
	potion_list_view.visible = false
	potion_detail_view.visible = true
	
	detail_title_label.text = potion_name
	
	var ingredients: Array = PotionJournal.get_ingredients_for_potion(potion_name)
	detail_ingredients_label.text = "Ingredients:\n" + "\n".join(ingredients)
	
	detail_image_1.texture = load("res://Assets/Sprites/Herb Bert/HerbBertBigHead.png") #placeholder for testing photos in journal
	detail_image_2.texture = load("res://Assets/Sprites/Herb Bert/HerbBertBald.png")  
	
	detail_notes_field.text = PotionJournal.get_note(potion_name)

func _on_notes_changed() -> void:
	if current_potion != "":
		PotionJournal.set_note(current_potion, detail_notes_field.text)
