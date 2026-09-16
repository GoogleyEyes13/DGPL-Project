extends Control
#region Variables
@onready var status_label: Label = $Panel/MarginContainer/VBoxContainer/StatusLabel
@onready var cauldron_label: Label = $Panel/MarginContainer/VBoxContainer/CauldronLabel
@onready var button_container: GridContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var log_scroll: ScrollContainer = $Panel/MarginContainer/VBoxContainer/LogScroll
@onready var log_label: RichTextLabel = $Panel/MarginContainer/VBoxContainer/LogScroll/LogLabel

const MAX_LOG_LINES := 100
var log_lines: Array[String] = []

var potion_types: Array[String] = [
	"Potion of Curing", "Potion of Rapid Shaking", "Potion of Permanent Smile",
	"Potion of Rabies", "Potion of Explode", "Potion of Change Language",
	"Potion of Mogging", "Potion of Body Swap", "Potion of Love",
	"Potion of Enlarge Person", "Potion of Shrink Person", "Potion Of Baldness",
	"Potion of Head Size Increase", "Potion of Head Size Decrease",
	"Potion of Green Skin", "Potion of Eye Colour Swap", "Potion of Skeleton",
	"Potion of Change Art Styles", "Potion of Creature Feature", "Potion of Beautification"
]
#endregion


func _ready() -> void:
	hide()
	button_container.add_theme_constant_override("h_separation", 10)
	button_container.add_theme_constant_override("v_separation", 10)
	_build_buttons()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	$"/root/Game/WitchCauldron".ingredients_updated.connect(_on_ingredients_updated)
	cauldron_label.text = ""

	DebugManager.log_message.connect(_on_log_message)
	
func _on_log_message(message: String) -> void:
	log_lines.append(message)
	if log_lines.size() > MAX_LOG_LINES:
		log_lines.pop_front()
	log_label.text = "\n".join(log_lines)
	
	await get_tree().process_frame
	log_scroll.scroll_vertical = int(log_scroll.get_v_scroll_bar().max_value)
	
func _on_ingredients_updated(ingredients: Array, last_potion: String) -> void:
	var ingredients_text: String
	if ingredients.is_empty():
		ingredients_text = "Cauldron: empty"
	else:
		var lines: Array[String] = []
		for ingredient in ingredients:
			lines.append("    - " + ingredient)
		ingredients_text = "Cauldron contains:\n" + "\n".join(lines)
	
	cauldron_label.text = ingredients_text + "\n\nLast potion: " + last_potion
	
func _process(_delta: float) -> void:
	if visible:
		_update_status()

func _update_status() -> void:
	if DebugManager.current_customer:
		var c = DebugManager.current_customer
		status_label.text = "Customer: %s | Ready: %s" % [c.CustomerName, c.cust_is_ready]
	else:
		status_label.text = "No customer registered"

func _build_buttons() -> void:
	for potion in potion_types:
		var button := Button.new()
		button.text = potion
		button.custom_minimum_size = Vector2(220, 44)
		button.add_theme_font_size_override("font_size", 16)
		button.pressed.connect(func(): DebugManager.trigger_potion(potion))
		button_container.add_child(button)
	print("Debug buttons built: ", button_container.get_child_count())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_T:
		visible = not visible
		DebugManager.toggle_debug()
