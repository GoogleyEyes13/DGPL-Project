extends CanvasLayer

@export_file("*.tscn") var main_menu_scene_path: String = "res://Scenes/MainMenu.tscn"

@onready var overlay: ColorRect = $Overlay
@onready var main_pause_vbox: VBoxContainer = $Overlay/CenterContainer/MainPauseVBox
@onready var options_menu_container: Control = $Overlay/CenterContainer/OptionsMenuContainer
@onready var settings_menu: Control = $Overlay/CenterContainer/OptionsMenuContainer/SettingsMenu

# Buttons
@onready var resume_button: Button = $Overlay/CenterContainer/MainPauseVBox/ResumeButton
@onready var restart_button: Button = $Overlay/CenterContainer/MainPauseVBox/RestartButton
@onready var options_button: Button = $Overlay/CenterContainer/MainPauseVBox/OptionsButton
@onready var main_menu_button: Button = $Overlay/CenterContainer/MainPauseVBox/MainMenuButton
@onready var quit_button: Button = $Overlay/CenterContainer/MainPauseVBox/QuitButton


func _ready() -> void:
	# Keep PauseMenu running even when tree pause is active
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100

	visible = false
	options_menu_container.visible = false
	main_pause_vbox.visible = true

	resume_button.pressed.connect(unpause_game)
	restart_button.pressed.connect(_on_restart_pressed)
	options_button.pressed.connect(_on_options_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	if settings_menu:
		if settings_menu.has_signal("back_pressed"):
			settings_menu.back_pressed.connect(_on_back_from_options)
		settings_menu.visibility_changed.connect(_on_settings_visibility_changed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		var cur = get_tree().current_scene
		# Only block pause if we are genuinely sitting in MainMenu
		if cur and cur.name.to_lower().contains("mainmenu"):
			return

		if get_tree().paused:
			if options_menu_container.visible:
				_on_back_from_options()
			else:
				unpause_game()
		else:
			pause_game()

		get_viewport().set_input_as_handled()


func pause_game() -> void:
	visible = true
	main_pause_vbox.visible = true
	options_menu_container.visible = false
	get_tree().paused = true
	resume_button.grab_focus()


func unpause_game() -> void:
	visible = false
	options_menu_container.visible = false
	get_tree().paused = false


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_options_pressed() -> void:
	main_pause_vbox.visible = false
	options_menu_container.visible = true
	if settings_menu:
		settings_menu.visible = true


func _on_settings_visibility_changed() -> void:
	if settings_menu and not settings_menu.visible and options_menu_container.visible:
		_on_back_from_options()


func _on_back_from_options() -> void:
	options_menu_container.visible = false
	if settings_menu:
		settings_menu.visible = false
	main_pause_vbox.visible = true
	options_button.grab_focus()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	visible = false
	if ResourceLoader.exists(main_menu_scene_path):
		get_tree().change_scene_to_file(main_menu_scene_path)
	else:
		push_error("Main menu scene path not found: " + main_menu_scene_path)


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
