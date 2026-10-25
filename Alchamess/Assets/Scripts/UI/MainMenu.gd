extends Control

@onready var canvas: Control = $ScreenCenter/AspectRatioContainer/Canvas

@onready var background: TextureRect = $ScreenCenter/AspectRatioContainer/Canvas/Background
@onready var garage_door: TextureRect = $ScreenCenter/AspectRatioContainer/Canvas/GarageDoor
@onready var menu_foreground: Node = $ScreenCenter/AspectRatioContainer/Canvas/MenuForeground

@onready var play_button: Button = $ScreenCenter/AspectRatioContainer/Canvas/PlayButton
@onready var settings_button: Button = $ScreenCenter/AspectRatioContainer/Canvas/SettingsButton
@onready var quit_button: Button = $ScreenCenter/AspectRatioContainer/Canvas/QuitButton
@onready var settings_menu: Control = $ScreenCenter/AspectRatioContainer/Canvas/SettingsMenu

@onready var click_sfx: AudioStreamPlayer = $ClickSFX
var sfx_click = preload("res://Assets/Audio/SFX/Menu/buttonclick.wav")

@export_file("*.tscn") var game_scene_path: String = "res://Scenes/Game.tscn"
@export var door_slide_duration: float = 0.8


func _ready() -> void:
	if not settings_button.pressed.is_connected(_on_settings_pressed):
		settings_button.pressed.connect(_on_settings_pressed)
		
	if not play_button.pressed.is_connected(_on_play_button_pressed):
		play_button.pressed.connect(_on_play_button_pressed)
		
	if not quit_button.pressed.is_connected(_on_quit_button_pressed):
		quit_button.pressed.connect(_on_quit_button_pressed)
	
	# Disable Play button until loading finishes
	play_button.disabled = true
	play_button.text = "Loading..."
	
	if background and garage_door:
		background.z_index = 0
		garage_door.z_index = 1
		# If you have MenuForeground or buttons, keep them above the garage door:
		if menu_foreground and menu_foreground is CanvasItem:
			menu_foreground.z_index = 2
			
	# Start background load
	ResourceLoader.load_threaded_request(game_scene_path)


func _process(_delta: float) -> void:
	if play_button.disabled:
		var status = ResourceLoader.load_threaded_get_status(game_scene_path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			play_button.disabled = false
			play_button.text = "Play"
			set_process(false)


func _play_click() -> void:
	if click_sfx:
		click_sfx.stream = sfx_click
		click_sfx.play()


func _on_play_button_pressed() -> void:
	_play_click()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Use the canvas height rather than viewport height so it matches your fixed layout
	var slide_distance: float = canvas.size.y if canvas else get_viewport_rect().size.y
	var slide_tween = create_tween()
	slide_tween.set_parallel(true)
	
	# Iterate over the children inside Canvas where the actual elements live
	if canvas:
		for child in canvas.get_children():
			# Keep the Background and Foreground stationary
			if child == background or child == menu_foreground or child == settings_menu:
				continue
			
			# Slide up the GarageDoor, title logo, buttons, etc.
			if child is Control:
				slide_tween.tween_property(
					child,
					"position:y",
					child.position.y - slide_distance,
					door_slide_duration
				).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Wait for all parallel slide tweens to finish before changing scenes
	slide_tween.set_parallel(false)
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
