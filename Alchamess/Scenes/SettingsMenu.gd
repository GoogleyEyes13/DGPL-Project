extends Control

const SETTINGS_PATH = "user://settings.cfg"

@onready var master_slider: HSlider = $Panel/MarginContainer/VBoxContainer/MasterVolumeRow/MasterSlider
@onready var music_slider: HSlider = $Panel/MarginContainer/VBoxContainer/MusicVolumeRow/MusicSlider
@onready var sfx_slider: HSlider = $Panel/MarginContainer/VBoxContainer/SFXVolumeRow/SFXSlider
@onready var back_button: Button = $Panel/MarginContainer/VBoxContainer/BackButton

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
	
	_load_settings()
	
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	back_button.pressed.connect(_on_back_pressed)
	
	hide()   # closed by default, MainMenu toggles this visible

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

func _save_settings() -> void:
	var config := ConfigFile.new()
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
