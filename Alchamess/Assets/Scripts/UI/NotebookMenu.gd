extends Control

#region Node References
@onready var book_button: TextureButton = $BookButton
@onready var panel: Control = $NotebookPanel

# Left Page (Ingredients)
@onready var ingredient_grid: GridContainer = $NotebookPanel/MarginContainer/BookSpread/LeftPage/IngredientsPanel/MarginContainer/IngredientGrid

# Right Page (Ingredient Showcase & Potion List)
@onready var right_page: Control = $NotebookPanel/MarginContainer/BookSpread/RightPage
@onready var potion_list_view: Control = right_page.get_node_or_null("PotionListView")

const POTION_BTN_NORMAL_TEX: Texture2D = preload("res://Assets/UI/JournalUI/NotebookAssets/PotionButtonNormal.png")
const POTION_BTN_HOVER_TEX: Texture2D = preload("res://Assets/UI/JournalUI/NotebookAssets/PotionButtonHover.png")
const POTION_BTN_CLICK_TEX: Texture2D = preload("res://Assets/UI/JournalUI/NotebookAssets/PotionButtonClick.png")

var style_normal: StyleBoxTexture
var style_hover: StyleBoxTexture
var style_pressed: StyleBoxTexture

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

# Resilient Polaroid lookups that support 'After' or 'AfterPolaroid' node naming
@onready var detail_image_1: TextureRect = (
	right_page.find_child("Image1", true, false) as TextureRect 
	if right_page else null
)
@onready var detail_image_2: TextureRect = (
	right_page.find_child("Image2", true, false) as TextureRect 
	if right_page else null
)

@onready var detail_ingredients_container: VBoxContainer = (
	right_page.get_node_or_null("PotionDetailView/DetailIngredientsContainer")
	if right_page.has_node("PotionDetailView/DetailIngredientsContainer")
	else right_page.get_node_or_null("PotionDetailView/DetailIngredientsLabel")
)
@onready var detail_notes_field: TextEdit = (
	right_page.get_node_or_null("PotionDetailView/TextEdit")
	if right_page.has_node("PotionDetailView/TextEdit")
	else right_page.get_node_or_null("PotionDetailView/DetailNotesField")
)

# Hover Tween Settings
@export var hover_scale: Vector2 = Vector2(0.22, 0.22)
@export var tween_duration: float = 0.15
var base_scale: Vector2 = Vector2.ONE
var scale_tween: Tween

var ingredient_names: Array = []
var current_ingredient: String = ""
var current_potion: String = ""

var default_before_texture: Texture2D = preload("res://Assets/Sprites/Herb Bert/HerbBertBigHead.png") if ResourceLoader.exists("res://Assets/Sprites/Herb Bert/HerbBertBigHead.png") else null
var default_after_texture: Texture2D = preload("res://Assets/Sprites/Herb Bert/HerbBertBald.png") if ResourceLoader.exists("res://Assets/Sprites/Herb Bert/HerbBertBald.png") else null

# Audio
@onready var notebook_sfx: AudioStreamPlayer = get_node_or_null("NotebookSFX")
var sfx_open: AudioStream = preload("res://Assets/Audio/SFX/Notebook/notebook open.wav")
var sfx_close: AudioStream = preload("res://Assets/Audio/SFX/Notebook/notebookclose.wav")
var sfx_forward: AudioStream = preload("res://Assets/Audio/SFX/Notebook/notebookforward.wav")
var sfx_backward: AudioStream = preload("res://Assets/Audio/SFX/Notebook/notebookbackward.wav")
#endregion


func _ready() -> void:
	style_normal = _create_potion_stylebox(POTION_BTN_NORMAL_TEX)
	style_hover = _create_potion_stylebox(POTION_BTN_HOVER_TEX)
	style_pressed = _create_potion_stylebox(POTION_BTN_CLICK_TEX)
	
	visible = true
	panel.visible = false
	book_button.visible = true
	book_button.focus_mode = Control.FOCUS_NONE
	
	base_scale = book_button.scale
	book_button.pivot_offset = book_button.size / 2.0
	book_button.pressed.connect(_on_book_pressed)
	book_button.mouse_entered.connect(_on_book_hover_enter)
	book_button.mouse_exited.connect(_on_book_hover_exit)
	
	var close_btn: BaseButton = panel.find_child("CloseButton", true, false) as BaseButton
	if close_btn:
		close_btn.pressed.connect(close_journal)
		
	if back_to_potions_button:
		back_to_potions_button.pressed.connect(_on_back_to_potions_pressed)
	if detail_notes_field:
		detail_notes_field.text_changed.connect(_on_notes_changed)
	
	ingredient_names = PotionDatabase.get_all_ingredient_names()
	_setup_ingredient_buttons()
	
	if potion_list_container:
		potion_list_container.add_theme_constant_override("h_separation", 10)
		potion_list_container.add_theme_constant_override("v_separation", 8)
		
	if PotionJournal:
		PotionJournal.NewIngredientUnlocked.connect(_on_ingredient_unlocked)


func _create_potion_stylebox(tex: Texture2D) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.texture_margin_left = 12.0
	sb.texture_margin_right = 12.0
	sb.texture_margin_top = 6.0
	sb.texture_margin_bottom = 6.0
	sb.content_margin_left = 10.0
	sb.content_margin_right = 10.0
	sb.content_margin_top = 4.0
	sb.content_margin_bottom = 4.0
	return sb


func _on_ingredient_unlocked(_ingredient_name: String) -> void:
	_update_ingredient_button_visibility()


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
	
	_update_ingredient_button_visibility()
	
	var unlocked: Array[String] = _get_unlocked_ingredients()
	if current_ingredient.is_empty() or not unlocked.has(current_ingredient):
		if not unlocked.is_empty():
			_on_ingredient_selected(unlocked[0])
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


func _get_unlocked_ingredients() -> Array[String]:
	if PotionJournal and PotionJournal.has_method("get_unlocked_ingredients"):
		return PotionJournal.get_unlocked_ingredients()
	return ["ElbowGrease", "OilOfVitriol", "Wormwood", "EyeOfNewt"]


func _update_ingredient_button_visibility() -> void:
	if not ingredient_grid:
		return
		
	var unlocked: Array[String] = _get_unlocked_ingredients()
	for ingredient in ingredient_names:
		var button: Button = ingredient_grid.get_node_or_null("Row_" + ingredient)
		if button:
			button.visible = unlocked.has(ingredient)


func _setup_ingredient_buttons() -> void:
	if not ingredient_grid:
		return
		
	for ingredient in ingredient_names:
		var button: Button = ingredient_grid.get_node_or_null("Row_" + ingredient)
		if not button:
			continue
		
		var icon: TextureRect = button.get_node_or_null("VBoxContainer/Icon")
		var label: Label = button.get_node_or_null("VBoxContainer/Label")
		var ing_data: Dictionary = PotionDatabase.get_ingredient_info(ingredient)
		
		if label:
			label.text = ing_data.get("display_name", ingredient)
		
		if icon:
			var icon_path: String = ing_data.get("icon", "")
			if ResourceLoader.exists(icon_path):
				icon.texture = load(icon_path)
		
		if not button.pressed.is_connected(_on_ingredient_selected):
			button.pressed.connect(_on_ingredient_selected.bind(ingredient))
			
	_update_ingredient_button_visibility()


func _on_ingredient_selected(ingredient: String) -> void:
	current_ingredient = ingredient
	_play_sfx(sfx_forward)
	_show_potion_list(ingredient)


func _show_potion_list(ingredient: String) -> void:
	if potion_detail_view:
		potion_detail_view.visible = false
	if potion_list_view:
		potion_list_view.visible = true
	
	var ing_data: Dictionary = PotionDatabase.get_ingredient_info(ingredient)
	
	if potion_list_header:
		potion_list_header.text = ing_data.get("display_name", ingredient) + " Recipes"
	
	var icon_path: String = ing_data.get("icon", "")
	if big_ingredient_icon and ResourceLoader.exists(icon_path):
		big_ingredient_icon.texture = load(icon_path)
		
	if ingredient_flavor_text:
		ingredient_flavor_text.text = ing_data.get("desc", "")
	
	if potion_list_container:
		for child in potion_list_container.get_children():
			potion_list_container.remove_child(child)
			child.queue_free()
	
	var unlocked_potions: Array = PotionJournal.get_potions_for_ingredient(ingredient)
	var total_potions_for_ingredient: int = PotionJournal.get_total_count_for_ingredient(ingredient)

	if total_potions_for_ingredient <= 0:
		total_potions_for_ingredient = 10

	if notebook_dial:
		notebook_dial.set_max_count(total_potions_for_ingredient)
		notebook_dial.update_count(unlocked_potions.size(), true)
		
	if dial_progress_label:
		dial_progress_label.text = "Discovered: %d / %d" % [unlocked_potions.size(), total_potions_for_ingredient]
		
	if unlocked_potions.is_empty():
		var label := Label.new()
		label.text = "No potions discovered yet with this ingredient."
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if potion_list_container:
			potion_list_container.add_child(label)
		return
	
	for potion_name in unlocked_potions:
		var button := _create_styled_potion_button(potion_name)
		button.pressed.connect(_on_potion_selected.bind(potion_name))
		if potion_list_container:
			potion_list_container.add_child(button)


func _create_styled_potion_button(potion_name: String) -> Button:
	var btn := Button.new()
	btn.text = potion_name
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, 48)
	btn.focus_mode = Control.FOCUS_NONE
	
	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	btn.add_theme_stylebox_override("focus", style_hover)
	
	btn.add_theme_font_size_override("font_size", 25)
	btn.add_theme_color_override("font_color", Color("3a2b1c"))
	btn.add_theme_color_override("font_hover_color", Color("1a120b"))
	btn.add_theme_color_override("font_pressed_color", Color("000000"))
	
	return btn


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
	
	# Populate Ingredients with clean vertical left alignment, 56x56 icons, and 34px font
	if detail_ingredients_container:
		for child in detail_ingredients_container.get_children():
			detail_ingredients_container.remove_child(child)
			child.queue_free()
			
		var ingredients: Array = PotionJournal.get_ingredients_for_potion(potion_name)
		for ing in ingredients:
			var row := HBoxContainer.new()
			row.alignment = BoxContainer.ALIGNMENT_BEGIN
			row.add_theme_constant_override("separation", 18)
			
			var ing_data: Dictionary = PotionDatabase.get_ingredient_info(str(ing))
			var icon_path: String = ing_data.get("icon", "")
			
			if ResourceLoader.exists(icon_path):
				var icon_rect := TextureRect.new()
				icon_rect.texture = load(icon_path)
				icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				icon_rect.custom_minimum_size = Vector2(56, 56)
				row.add_child(icon_rect)
			
			var name_label := Label.new()
			name_label.text = PotionDatabase.get_ingredient_display_name(str(ing))
			name_label.add_theme_font_size_override("font_size", 34)
			name_label.add_theme_color_override("font_color", Color("3a2b1c"))
			name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			row.add_child(name_label)
			
			detail_ingredients_container.add_child(row)

	var customer_name: String = PotionJournal.get_potion_customer(potion_name)
	var portraits: Dictionary = _get_customer_portraits(customer_name, potion_name)
	
	if detail_image_1:
		detail_image_1.texture = portraits["before"]
	if detail_image_2:
		detail_image_2.texture = portraits["after"]
	
	if detail_notes_field:
		detail_notes_field.text = PotionJournal.get_note(potion_name)


func _get_customer_portraits(customer_name: String, potion_name: String) -> Dictionary:
	var raw_name: String = customer_name.strip_edges()
	
	# Fallback if no customer was recorded yet
	if raw_name.is_empty():
		if DebugManager.current_customer and "CustomerName" in DebugManager.current_customer:
			raw_name = DebugManager.current_customer.CustomerName
		else:
			raw_name = "HerbBert"

	var info: Dictionary = PotionDatabase.get_potion_info_by_name(potion_name)
	var suffix: String = info.get("suffix", "Normal")

	var before_path: String = CharacterData.get_sprite_path(raw_name, "Normal")
	var after_path: String = CharacterData.get_sprite_path(raw_name, suffix)

	var before_tex: Texture2D = null
	if ResourceLoader.exists(before_path):
		before_tex = load(before_path)
	elif default_before_texture:
		before_tex = default_before_texture

	var after_tex: Texture2D = null
	if ResourceLoader.exists(after_path):
		after_tex = load(after_path)
	elif default_after_texture:
		after_tex = default_after_texture
	else:
		# Ultimate fallback: reuse before portrait so the polaroid is never empty
		after_tex = before_tex

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
	elif panel.visible and event.is_action_pressed("ui_cancel"):
		close_journal()
		get_viewport().set_input_as_handled()
