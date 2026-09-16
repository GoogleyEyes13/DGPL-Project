extends Control

const SETTINGS_PATH = "user://settings.cfg"

@onready var master_slider: HSlider = $Panel/MarginContainer/ScrollContainer/VBoxContainer/MasterVolumeRow/MasterSlider
@onready var music_slider: HSlider = $Panel/MarginContainer/ScrollContainer/VBoxContainer/MusicVolumeRow/MusicSlider
@onready var sfx_slider: HSlider = $Panel/MarginContainer/ScrollContainer/VBoxContainer/SFXVolumeRow/SFXSlider
@onready var back_button: Button = $Panel/MarginContainer/ScrollContainer/VBoxContainer/BackButton
@onready var keybind_container: VBoxContainer = $Panel/MarginContainer/ScrollContainer/VBoxContainer/KeybindContainer
@onready var resolution_dropdown: OptionButton = $Panel/MarginContainer/ScrollContainer/VBoxContainer/ResolutionDropdown
@onready var fullscreen_checkbox: CheckBox = $Panel/MarginContainer/ScrollContainer/VBoxContainer/FullscreenCheckBox

var rebindable_actions: Array[String] = ["toggle_journal", "give_potion", "toggle_debug_menu"]
var action_labels: Dictionary = {
	"toggle_journal": "Open/Close Journal",
	"give_potion": "Give Potion",
	"toggle_debug_menu": "Open/Close Debug Menu"
}

var listening_for_action: String = ""
var rebind_buttons: Dictionary = {}

var resolutions: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
]

func _ready() -> void:
	master_slider.min_value = 0.0
	master_slider.max_value = 1.0
	master_slider.step = 0.01
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	music_slider.step = 0.01
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.01
	
	_build_resolution_dropdown()
	_load_settings()
	_build_keybind_rows()
	
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	back_button.pressed.connect(_on_back_pressed)
	resolution_dropdown.item_selected.connect(_on_resolution_selected)
	fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
	
	hide()

func _build_resolution_dropdown() -> void:
	resolution_dropdown.clear()
	for res in resolutions:
		resolution_dropdown.add_item("%d x %d" % [res.x, res.y])

func _on_resolution_selected(index: int) -> void:
	var res = resolutions[index]
	DisplayServer.window_set_size(res)
	_center_window()
	_save_display_settings()

func _on_fullscreen_toggled(pressed: bool) -> void:
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_save_display_settings()

func _center_window() -> void:
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	DisplayServer.window_set_position((screen_size - window_size) / 2)

func _save_display_settings() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("display", "resolution_index", resolution_dropdown.selected)
	config.set_value("display", "fullscreen", fullscreen_checkbox.button_pressed)
	config.save(SETTINGS_PATH)

func _load_display_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)
	if err != OK:
		return
	
	var res_index: int = config.get_value("display", "resolution_index", 2)   # default: 1920x1080
	var fullscreen: bool = config.get_value("display", "fullscreen", false)
	
	resolution_dropdown.select(res_index)
	fullscreen_checkbox.button_pressed = fullscreen
	
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(resolutions[res_index])
		_center_window()

func _build_keybind_rows() -> void:
	for action in rebindable_actions:
		var row := HBoxContainer.new()
		
		var label := Label.new()
		label.text = action_labels.get(action, action)
		label.custom_minimum_size = Vector2(220, 0)
		row.add_child(label)
		
		var button := Button.new()
		button.text = _get_key_display(action)
		button.custom_minimum_size = Vector2(140, 36)
		button.pressed.connect(func(): _start_listening(action, button))
		row.add_child(button)
		
		rebind_buttons[action] = button
		keybind_container.add_child(row)

func _get_key_display(action: String) -> String:
	var events = InputMap.action_get_events(action)
	if events.size() > 0:
		return events[0].as_text()
	return "Unbound"

func _start_listening(action: String, button: Button) -> void:
	listening_for_action = action
	button.text = "Press a key..."

func _unhandled_input(event: InputEvent) -> void:
	if listening_for_action == "":
		return
	
	if event is InputEventKey and event.pressed:
		InputMap.action_erase_events(listening_for_action)
		InputMap.action_add_event(listening_for_action, event)
		
		rebind_buttons[listening_for_action].text = event.as_text()
		_save_keybind(listening_for_action, event)
		
		listening_for_action = ""
		get_viewport().set_input_as_handled()

func _save_keybind(action: String, event: InputEventKey) -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("keybinds", action, event.keycode)
	config.save(SETTINGS_PATH)

func _load_keybinds() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)
	if err != OK:
		return
	
	for action in rebindable_actions:
		if config.has_section_key("keybinds", action):
			var keycode: int = config.get_value("keybinds", action)
			var new_event := InputEventKey.new()
			new_event.keycode = keycode
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, new_event)

func _load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)
	
	var master_vol: float = 1.0
	var music_vol: float = 1.0
	var sfx_vol: float = 1.0
	
	if err == OK:
		master_vol = config.get_value("audio", "master", 1.0)
		music_vol = config.get_value("audio", "music", 1.0)
		sfx_vol = config.get_value("audio", "sfx", 1.0)
	
	master_slider.value = master_vol
	music_slider.value = music_vol
	sfx_slider.value = sfx_vol
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_vol))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_vol))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_vol))
	
	_load_keybinds()
	_load_display_settings()

func _save_settings() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("audio", "master", master_slider.value)
	config.set_value("audio", "music", music_slider.value)
	config.set_value("audio", "sfx", sfx_slider.value)
	config.save(SETTINGS_PATH)

func _on_master_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	_save_settings()

func _on_music_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	_save_settings()

func _on_sfx_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
	_save_settings()

func _on_back_pressed() -> void:
	hide()
