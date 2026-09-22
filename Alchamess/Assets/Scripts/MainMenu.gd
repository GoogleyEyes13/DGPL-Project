extends Control

@onready var settings_button: Button = $SettingsButton
@onready var settings_menu: Control = $SettingsMenu

@onready var click_sfx: AudioStreamPlayer = $ClickSFX
var sfx_click = preload("res://Assets/Audio/SFX/Menu/buttonclick.wav")

func _ready() -> void:
	settings_button.pressed.connect(_on_settings_pressed)

func _play_click() -> void:
	click_sfx.stream = sfx_click
	click_sfx.play()

func _on_play_button_pressed() -> void:
	_play_click()
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_settings_pressed() -> void:
	_play_click()
	settings_menu.show()

func _on_quit_button_pressed() -> void:
	_play_click()
	get_tree().quit()
