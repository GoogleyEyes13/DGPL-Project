extends Control
class_name PotionPopup

@onready var panel_container: PanelContainer = $PanelContainer
@onready var potion_icon: TextureRect = $PanelContainer/MarginContainer/HBoxContainer/PotionIcon
@onready var potion_name_label: RichTextLabel = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/PotionNameLabel
@onready var subtitle_label: Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/SubtitleLabel
@onready var ingredients_box: HBoxContainer = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/IngredientsBox

@export var slide_offset: Vector2 = Vector2(250, 0)
@export var display_duration: float = 2.5

var anim_tween: Tween
var resting_pos: Vector2


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	resting_pos = position


func display_potion(potion_name: String, ingredients: Array = []) -> void:
	# 1. Fetch Potion Data & format bold using BBCode
	var info: Dictionary = PotionDatabase.get_potion_info_by_name(potion_name)
	potion_name_label.text = "[b]" + potion_name + "[/b]"

	if ingredients.is_empty():
		for recipe_ings in PotionDatabase.RECIPES.keys():
			if PotionDatabase.RECIPES[recipe_ings]["name"] == potion_name:
				ingredients = recipe_ings.duplicate()
				break

	# 2. Potion Texture
	var bottle_tex_path: String = "res://Assets/Sprites/Potions/" + potion_name + ".png"
	if ResourceLoader.exists(bottle_tex_path):
		potion_icon.texture = load(bottle_tex_path)
	elif ResourceLoader.exists("res://Assets/Sprites/Potions/EmptyPotionBottle.png"):
		potion_icon.texture = load("res://Assets/Sprites/Potions/EmptyPotionBottle.png")

	# 3. Clean up existing ingredient icons immediately
	for child in ingredients_box.get_children():
		ingredients_box.remove_child(child)
		child.queue_free()

	for ing in ingredients:
		var ing_data: Dictionary = PotionDatabase.get_ingredient_info(str(ing))
		var icon_path: String = ing_data.get("icon", "")
		if ResourceLoader.exists(icon_path):
			var icon_rect := TextureRect.new()
			icon_rect.texture = load(icon_path)
			icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon_rect.custom_minimum_size = Vector2(48, 48)
			ingredients_box.add_child(icon_rect)

	# 4. Trigger animation
	_animate_banner()


func _animate_banner() -> void:
	if anim_tween and anim_tween.is_valid():
		anim_tween.kill()

	visible = true
	modulate.a = 0.0
	position = resting_pos + slide_offset

	anim_tween = create_tween()

	# Slide & Fade In
	anim_tween.tween_property(self, "position", resting_pos, 0.35)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	anim_tween.parallel().tween_property(self, "modulate:a", 1.0, 0.2)

	# Hold
	anim_tween.tween_interval(display_duration)

	# Slide & Fade Out
	anim_tween.tween_property(self, "position", resting_pos + slide_offset, 0.3)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	anim_tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)

	# Hide
	anim_tween.tween_callback(func():
		visible = false
	)
