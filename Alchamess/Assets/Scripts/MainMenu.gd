extends Control

@onready var settings_button: Button = $SettingsButton
@onready var settings_menu: Control = $SettingsMenu

func _ready() -> void:
	settings_button.pressed.connect(_on_settings_pressed)

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_settings_pressed() -> void:
	settings_menu.show()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
