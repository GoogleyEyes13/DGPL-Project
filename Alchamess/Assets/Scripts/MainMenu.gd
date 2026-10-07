extends Control

@onready var settings_button: Button = $SettingsButton
@onready var settings_menu: Control = $SettingsMenu
@onready var play_button: Button = $PlayButton
@onready var quit_button: Button = $QuitButton

@onready var click_sfx: AudioStreamPlayer = $ClickSFX
var sfx_click = preload("res://Assets/Audio/SFX/Menu/buttonclick.wav")

@export_file("*.tscn") var game_scene_path: String = "res://Scenes/Game.tscn"
@export var door_slide_duration: float = 0.8


func _ready() -> void:
	settings_button.pressed.connect(_on_settings_pressed)
	play_button.pressed.connect(_on_play_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	
	# Disable Play button until loading finishes
	play_button.disabled = true
	
	# Start background load
	ResourceLoader.load_threaded_request(game_scene_path)


func _process(_delta: float) -> void:
	# Check if the button is still disabled and update load status
	if play_button.disabled:
		var status = ResourceLoader.load_threaded_get_status(game_scene_path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			play_button.disabled = false
			set_process(false) # Stop checking every frame once loaded


func _play_click() -> void:
	click_sfx.stream = sfx_click
	click_sfx.play()


func _on_play_button_pressed() -> void:
	_play_click()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var screen_height = get_viewport_rect().size.y
	var slide_tween = create_tween()
	
	slide_tween.tween_property(
		self, 
		"position:y", 
		-screen_height, 
		door_slide_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	slide_tween.tween_callback(change_to_preloaded_game)


func change_to_preloaded_game() -> void:
	var packed_game_scene: PackedScene = ResourceLoader.load_threaded_get(game_scene_path)
	
	if packed_game_scene:
		get_tree().change_scene_to_packed(packed_game_scene)
	else:
		get_tree().change_scene_to_file(game_scene_path)


func _on_settings_pressed() -> void:
	_play_click()
	settings_menu.show()


func _on_quit_button_pressed() -> void:
	_play_click()
	get_tree().quit()
