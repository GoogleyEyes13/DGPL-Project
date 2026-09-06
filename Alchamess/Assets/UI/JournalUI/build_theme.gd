extends SceneTree

const THEME_PATH := "res://resources/bento_sketch/bento_sketch.tres"
const INK := Color("282722")
const PAPER := Color("fffcef")
const PAPER_DEEP := Color("f4edd0")
const CANVAS := Color("f4f3e8")
const WOOD := Color("ddca8f")
const CORAL := Color("d97b5c")
const CORAL_DARK := Color("b85f45")
const GREEN := Color("a9c55a")
const MUSTARD := Color("e3bd43")
const MUTED := Color("746f61")
const DISABLED := Color("c8c4b7")


func _initialize() -> void:
	call_deferred("_build")


func _build() -> void:
	var theme := Theme.new()
	var font := load("res://resources/bento_sketch/fonts/PatrickHand-Regular.ttf") as Font
	if font == null:
		push_error("Patrick Hand failed to load.")
		quit(1)
		return

	theme.default_font = font
	theme.default_font_size = 24
	_set_label_styles(theme)
	_set_panel_styles(theme)
	_set_button_styles(theme)
	_set_input_styles(theme)
	_set_selection_styles(theme)
	_set_feedback_styles(theme)
	_set_advanced_text_styles(theme)
	_set_navigation_styles(theme)
	_set_data_styles(theme)
	_set_scroll_styles(theme)
	_set_dialog_styles(theme)

	var error := ResourceSaver.save(theme, THEME_PATH)
	if error != OK:
		push_error("Could not save Bento Sketch theme: %s" % error_string(error))
		quit(1)
		return
	print("Saved %s" % THEME_PATH)
	quit()


func _set_label_styles(theme: Theme) -> void:
	theme.set_color("font_color", "Label", INK)
	theme.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0))
	theme.set_color("default_color", "RichTextLabel", INK)
	theme.set_color("font_color", "Button", INK)

	theme.set_type_variation("BentoTitle", "Label")
	theme.set_font_size("font_size", "BentoTitle", 48)
	theme.set_color("font_color", "BentoTitle", INK)

	theme.set_type_variation("BentoSectionTitle", "Label")
	theme.set_font_size("font_size", "BentoSectionTitle", 31)
	theme.set_color("font_color", "BentoSectionTitle", INK)

	theme.set_type_variation("BentoMutedLabel", "Label")
	theme.set_font_size("font_size", "BentoMutedLabel", 20)
	theme.set_color("font_color", "BentoMutedLabel", MUTED)

	theme.set_type_variation("BentoBadge", "Label")
	theme.set_font_size("font_size", "BentoBadge", 19)
	theme.set_color("font_color", "BentoBadge", INK)
	theme.set_stylebox("normal", "BentoBadge", _make_flat(Color("f8e8b2"), INK, 2, 14, Vector4(12, 4, 12, 5)))


func _set_panel_styles(theme: Theme) -> void:
	var base_panel := _make_flat(CANVAS, Color(0, 0, 0, 0), 0, 0, Vector4(0, 0, 0, 0))
	theme.set_stylebox("panel", "Panel", base_panel)
	theme.set_stylebox("panel", "PanelContainer", _make_flat(PAPER_DEEP, INK, 3, 20, Vector4(22, 20, 22, 22)))

	var paper_texture := load("res://resources/bento_sketch/textures/irregular_paper_frame.svg") as Texture2D
	var wood_texture := load("res://resources/bento_sketch/textures/wood_header_frame.svg") as Texture2D

	theme.set_type_variation("BentoCard", "PanelContainer")
	theme.set_stylebox("panel", "BentoCard", _make_texture_box(paper_texture, 52, Vector4(30, 28, 30, 30)))

	theme.set_type_variation("BentoWoodPanel", "PanelContainer")
	theme.set_stylebox("panel", "BentoWoodPanel", _make_texture_box(wood_texture, 48, Vector4(30, 22, 30, 24)))

	theme.set_type_variation("BentoSidebarPanel", "PanelContainer")
	var sidebar := _make_flat(Color("eeeadd"), INK, 3, 22, Vector4(22, 24, 22, 24))
	sidebar.border_width_right = 5
	theme.set_stylebox("panel", "BentoSidebarPanel", sidebar)

	theme.set_stylebox("panel", "TooltipPanel", _make_flat(INK, INK, 2, 8, Vector4(12, 8, 12, 9)))
	theme.set_color("font_color", "TooltipLabel", PAPER)
	theme.set_font_size("font_size", "TooltipLabel", 19)


func _set_button_styles(theme: Theme) -> void:
	var normal := _make_flat(Color("fffdf4"), INK, 3, 16, Vector4(18, 10, 18, 11))
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("f8e8b2")
	hover.border_color = Color("3a382f")
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = WOOD
	pressed.border_color = INK
	pressed.content_margin_top = 12
	pressed.content_margin_bottom = 9
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color("e4e1d6")
	disabled.border_color = Color("aaa698")
	var focus := _make_flat(Color(0, 0, 0, 0), MUSTARD, 4, 19, Vector4(0, 0, 0, 0))
	focus.expand_margin_left = 4
	focus.expand_margin_top = 4
	focus.expand_margin_right = 4
	focus.expand_margin_bottom = 4

	_apply_button_set(theme, "Button", normal, hover, pressed, disabled, focus)
	_apply_button_set(theme, "OptionButton", normal, hover, pressed, disabled, focus)
	theme.set_icon("arrow", "OptionButton", load("res://resources/bento_sketch/icons/arrow_down.svg"))
	theme.set_constant("arrow_margin", "OptionButton", 14)
	theme.set_constant("modulate_arrow", "OptionButton", 0)

	theme.set_type_variation("BentoPrimaryButton", "Button")
	var primary_normal := normal.duplicate() as StyleBoxFlat
	primary_normal.bg_color = CORAL
	var primary_hover := hover.duplicate() as StyleBoxFlat
	primary_hover.bg_color = Color("e79373")
	var primary_pressed := pressed.duplicate() as StyleBoxFlat
	primary_pressed.bg_color = CORAL_DARK
	theme.set_stylebox("normal", "BentoPrimaryButton", primary_normal)
	theme.set_stylebox("hover", "BentoPrimaryButton", primary_hover)
	theme.set_stylebox("pressed", "BentoPrimaryButton", primary_pressed)
	theme.set_stylebox("disabled", "BentoPrimaryButton", disabled)
	theme.set_stylebox("focus", "BentoPrimaryButton", focus)
	theme.set_color("font_color", "BentoPrimaryButton", Color.WHITE)
	theme.set_color("font_hover_color", "BentoPrimaryButton", Color.WHITE)
	theme.set_color("font_pressed_color", "BentoPrimaryButton", Color.WHITE)
	theme.set_color("font_focus_color", "BentoPrimaryButton", Color.WHITE)
	theme.set_color("font_disabled_color", "BentoPrimaryButton", Color("8c887c"))

	theme.set_type_variation("BentoQuietButton", "Button")
	var quiet := _make_flat(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 8, Vector4(14, 8, 14, 9))
	var quiet_hover := quiet.duplicate() as StyleBoxFlat
	quiet_hover.bg_color = Color("dfdac7")
	var quiet_pressed := quiet_hover.duplicate() as StyleBoxFlat
	quiet_pressed.bg_color = WOOD
	theme.set_stylebox("normal", "BentoQuietButton", quiet)
	theme.set_stylebox("hover", "BentoQuietButton", quiet_hover)
	theme.set_stylebox("pressed", "BentoQuietButton", quiet_pressed)
	theme.set_stylebox("disabled", "BentoQuietButton", quiet)
	theme.set_stylebox("focus", "BentoQuietButton", focus)


func _set_input_styles(theme: Theme) -> void:
	var normal := _make_flat(Color("fffef7"), INK, 3, 15, Vector4(14, 10, 14, 10))
	var focus := normal.duplicate() as StyleBoxFlat
	focus.border_color = MUSTARD
	focus.border_width_left = 4
	focus.border_width_top = 4
	focus.border_width_right = 4
	focus.border_width_bottom = 4
	var read_only := normal.duplicate() as StyleBoxFlat
	read_only.bg_color = Color("e8e5da")
	read_only.border_color = Color("aaa698")

	for control_type in ["LineEdit", "TextEdit"]:
		theme.set_stylebox("normal", control_type, normal)
		theme.set_stylebox("focus", control_type, focus)
		theme.set_stylebox("read_only", control_type, read_only)
		theme.set_color("font_color", control_type, INK)
		theme.set_color("font_placeholder_color", control_type, Color("8b8678"))
		theme.set_color("font_uneditable_color", control_type, Color("817d72"))
		theme.set_color("caret_color", control_type, CORAL_DARK)
		theme.set_color("selection_color", control_type, Color("e7c976"))

	theme.set_constant("minimum_character_width", "LineEdit", 4)


func _set_selection_styles(theme: Theme) -> void:
	var unchecked := load("res://resources/bento_sketch/icons/checkbox_unchecked.svg") as Texture2D
	var checked := load("res://resources/bento_sketch/icons/checkbox_checked.svg") as Texture2D
	theme.set_icon("unchecked", "CheckBox", unchecked)
	theme.set_icon("checked", "CheckBox", checked)
	theme.set_icon("unchecked_disabled", "CheckBox", unchecked)
	theme.set_icon("checked_disabled", "CheckBox", checked)
	theme.set_color("font_color", "CheckBox", INK)
	theme.set_color("font_hover_color", "CheckBox", CORAL_DARK)
	theme.set_color("font_pressed_color", "CheckBox", CORAL_DARK)
	theme.set_color("font_disabled_color", "CheckBox", Color("999589"))
	theme.set_constant("h_separation", "CheckBox", 12)

	var focus := _make_flat(Color(0, 0, 0, 0), MUSTARD, 3, 8, Vector4(0, 0, 0, 0))
	focus.expand_margin_left = 4
	focus.expand_margin_top = 3
	focus.expand_margin_right = 4
	focus.expand_margin_bottom = 3
	theme.set_stylebox("focus", "CheckBox", focus)

	var toggle_off := load("res://resources/bento_sketch/icons/toggle_off.svg") as Texture2D
	var toggle_on := load("res://resources/bento_sketch/icons/toggle_on.svg") as Texture2D
	for icon_name in ["unchecked", "unchecked_disabled", "unchecked_mirrored", "unchecked_disabled_mirrored"]:
		theme.set_icon(icon_name, "CheckButton", toggle_off)
	for icon_name in ["checked", "checked_disabled", "checked_mirrored", "checked_disabled_mirrored"]:
		theme.set_icon(icon_name, "CheckButton", toggle_on)
	for color_name in ["font_color", "font_pressed_color", "font_hover_color", "font_hover_pressed_color", "font_focus_color"]:
		theme.set_color(color_name, "CheckButton", INK)
	theme.set_color("font_disabled_color", "CheckButton", Color("999589"))
	theme.set_color("button_checked_color", "CheckButton", Color.WHITE)
	theme.set_color("button_unchecked_color", "CheckButton", Color.WHITE)
	theme.set_constant("h_separation", "CheckButton", 12)
	var transparent := _make_flat(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 10, Vector4(6, 5, 6, 5))
	for style_name in ["normal", "pressed", "disabled", "hover", "hover_pressed"]:
		theme.set_stylebox(style_name, "CheckButton", transparent)
	theme.set_stylebox("focus", "CheckButton", focus)

	theme.set_type_variation("RadioButton", "CheckBox")
	theme.set_icon("unchecked", "RadioButton", load("res://resources/bento_sketch/icons/radio_unchecked.svg"))
	theme.set_icon("checked", "RadioButton", load("res://resources/bento_sketch/icons/radio_checked.svg"))
	theme.set_icon("unchecked_disabled", "RadioButton", load("res://resources/bento_sketch/icons/radio_unchecked.svg"))
	theme.set_icon("checked_disabled", "RadioButton", load("res://resources/bento_sketch/icons/radio_checked.svg"))


func _set_feedback_styles(theme: Theme) -> void:
	var separator := StyleBoxLine.new()
	separator.color = INK
	separator.thickness = 3
	separator.grow_begin = 5
	separator.grow_end = 5
	theme.set_stylebox("separator", "HSeparator", separator)
	theme.set_constant("separation", "HSeparator", 14)

	var progress_bg := _make_flat(Color("e1ddce"), INK, 3, 15, Vector4(5, 5, 5, 5))
	var progress_fill := _make_flat(GREEN, INK, 2, 12, Vector4(7, 4, 7, 4))
	theme.set_stylebox("background", "ProgressBar", progress_bg)
	theme.set_stylebox("fill", "ProgressBar", progress_fill)
	theme.set_color("font_color", "ProgressBar", INK)
	theme.set_color("font_outline_color", "ProgressBar", PAPER)
	theme.set_constant("outline_size", "ProgressBar", 2)

	var slider := _make_flat(Color("ded9c6"), INK, 2, 5, Vector4(0, 4, 0, 4))
	var grabber_area := _make_flat(GREEN, INK, 2, 5, Vector4(0, 4, 0, 4))
	var grabber_area_hover := grabber_area.duplicate() as StyleBoxFlat
	grabber_area_hover.bg_color = Color("bbd36d")
	theme.set_stylebox("slider", "HSlider", slider)
	theme.set_stylebox("grabber_area", "HSlider", grabber_area)
	theme.set_stylebox("grabber_area_highlight", "HSlider", grabber_area_hover)
	var grabber := load("res://resources/bento_sketch/icons/slider_grabber.svg") as Texture2D
	theme.set_icon("grabber", "HSlider", grabber)
	theme.set_icon("grabber_highlight", "HSlider", grabber)
	theme.set_icon("grabber_disabled", "HSlider", grabber)


func _set_advanced_text_styles(theme: Theme) -> void:
	var transparent := _make_flat(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 8, Vector4(8, 6, 8, 6))
	var focus := _make_flat(Color(0, 0, 0, 0), MUSTARD, 3, 10, Vector4(8, 6, 8, 6))
	theme.set_stylebox("normal", "RichTextLabel", transparent)
	theme.set_stylebox("focus", "RichTextLabel", focus)
	theme.set_color("default_color", "RichTextLabel", INK)
	theme.set_color("font_selected_color", "RichTextLabel", INK)
	theme.set_color("selection_color", "RichTextLabel", Color("e7c976"))
	theme.set_color("table_odd_row_bg", "RichTextLabel", Color("eee8d1"))
	theme.set_color("table_even_row_bg", "RichTextLabel", Color("fffcef"))
	theme.set_color("table_border", "RichTextLabel", INK)
	for size_name in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size", "mono_font_size"]:
		theme.set_font_size(size_name, "RichTextLabel", 22)

	theme.set_color("font_color", "LinkButton", CORAL_DARK)
	theme.set_color("font_hover_color", "LinkButton", CORAL)
	theme.set_color("font_pressed_color", "LinkButton", INK)
	theme.set_color("font_focus_color", "LinkButton", CORAL_DARK)
	theme.set_constant("underline_spacing", "LinkButton", 4)
	theme.set_font_size("font_size", "LinkButton", 22)
	theme.set_stylebox("focus", "LinkButton", focus)

	var code_normal := theme.get_stylebox("normal", "TextEdit").duplicate() as StyleBoxFlat
	var code_focus := theme.get_stylebox("focus", "TextEdit").duplicate() as StyleBoxFlat
	var code_read_only := theme.get_stylebox("read_only", "TextEdit").duplicate() as StyleBoxFlat
	code_normal.bg_color = Color("f7f3df")
	code_read_only.bg_color = Color("e8e5da")
	theme.set_stylebox("normal", "CodeEdit", code_normal)
	theme.set_stylebox("focus", "CodeEdit", code_focus)
	theme.set_stylebox("read_only", "CodeEdit", code_read_only)
	theme.set_stylebox("completion", "CodeEdit", _make_flat(PAPER, INK, 2, 8, Vector4(8, 6, 8, 6)))
	theme.set_color("background_color", "CodeEdit", Color(0, 0, 0, 0))
	theme.set_color("font_color", "CodeEdit", INK)
	theme.set_color("font_readonly_color", "CodeEdit", MUTED)
	theme.set_color("font_placeholder_color", "CodeEdit", Color("8b8678"))
	theme.set_color("selection_color", "CodeEdit", Color("e7c976"))
	theme.set_color("current_line_color", "CodeEdit", Color("eee6c5"))
	theme.set_color("line_number_color", "CodeEdit", Color("968e75"))
	theme.set_color("caret_color", "CodeEdit", CORAL_DARK)
	theme.set_color("brace_mismatch_color", "CodeEdit", CORAL_DARK)
	theme.set_color("code_folding_color", "CodeEdit", MUTED)
	theme.set_color("completion_background_color", "CodeEdit", PAPER)
	theme.set_color("completion_selected_color", "CodeEdit", WOOD)
	theme.set_font_size("font_size", "CodeEdit", 20)

	var up := load("res://resources/bento_sketch/icons/chevron_up.svg") as Texture2D
	var down := load("res://resources/bento_sketch/icons/chevron_down.svg") as Texture2D
	for icon_name in ["up", "up_hover", "up_pressed", "up_disabled"]:
		theme.set_icon(icon_name, "SpinBox", up)
	for icon_name in ["down", "down_hover", "down_pressed", "down_disabled"]:
		theme.set_icon(icon_name, "SpinBox", down)
	theme.set_icon("updown", "SpinBox", down)
	var spin_normal := _make_flat(PAPER_DEEP, INK, 2, 7, Vector4(4, 2, 4, 2))
	var spin_hover := spin_normal.duplicate() as StyleBoxFlat
	spin_hover.bg_color = Color("f8e8b2")
	var spin_pressed := spin_normal.duplicate() as StyleBoxFlat
	spin_pressed.bg_color = WOOD
	for prefix in ["up", "down"]:
		theme.set_stylebox(prefix + "_background", "SpinBox", spin_normal)
		theme.set_stylebox(prefix + "_background_hovered", "SpinBox", spin_hover)
		theme.set_stylebox(prefix + "_background_pressed", "SpinBox", spin_pressed)
		theme.set_stylebox(prefix + "_background_disabled", "SpinBox", spin_normal)
	theme.set_constant("buttons_width", "SpinBox", 30)
	theme.set_constant("buttons_vertical_separation", "SpinBox", 1)


func _set_navigation_styles(theme: Theme) -> void:
	var tab_normal := _make_flat(Color("eee9d7"), INK, 2, 13, Vector4(15, 8, 15, 9))
	var tab_hover := tab_normal.duplicate() as StyleBoxFlat
	tab_hover.bg_color = Color("f8e8b2")
	var tab_selected := tab_normal.duplicate() as StyleBoxFlat
	tab_selected.bg_color = CORAL
	var tab_disabled := tab_normal.duplicate() as StyleBoxFlat
	tab_disabled.bg_color = Color("dfdcd1")
	tab_disabled.border_color = Color("aaa698")
	var tab_focus := _make_flat(Color(0, 0, 0, 0), MUSTARD, 3, 15, Vector4(0, 0, 0, 0))
	for control_type in ["TabBar", "TabContainer"]:
		theme.set_stylebox("tab_selected", control_type, tab_selected)
		theme.set_stylebox("tab_hovered", control_type, tab_hover)
		theme.set_stylebox("tab_unselected", control_type, tab_normal)
		theme.set_stylebox("tab_disabled", control_type, tab_disabled)
		theme.set_stylebox("tab_focus", control_type, tab_focus)
		theme.set_color("font_selected_color", control_type, Color.WHITE)
		theme.set_color("font_hovered_color", control_type, INK)
		theme.set_color("font_unselected_color", control_type, INK)
		theme.set_color("font_disabled_color", control_type, Color("999589"))
		theme.set_font_size("font_size", control_type, 22)
	theme.set_icon("close", "TabBar", load("res://resources/bento_sketch/icons/close.svg"))
	theme.set_icon("menu", "TabContainer", load("res://resources/bento_sketch/icons/menu.svg"))
	theme.set_icon("menu_highlight", "TabContainer", load("res://resources/bento_sketch/icons/menu.svg"))
	theme.set_stylebox("panel", "TabContainer", _make_flat(PAPER, INK, 3, 17, Vector4(18, 18, 18, 18)))
	theme.set_stylebox("tabbar_background", "TabContainer", _make_flat(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 0, Vector4(0, 0, 0, 0)))

	var popup_panel := _make_flat(PAPER, INK, 3, 14, Vector4(8, 8, 8, 8))
	popup_panel.shadow_color = Color(0.12, 0.11, 0.09, 0.24)
	popup_panel.shadow_size = 8
	popup_panel.shadow_offset = Vector2(3, 5)
	theme.set_stylebox("panel", "PopupMenu", popup_panel)
	theme.set_stylebox("hover", "PopupMenu", _make_flat(WOOD, INK, 2, 8, Vector4(8, 5, 8, 5)))
	var separator := StyleBoxLine.new()
	separator.color = INK
	separator.thickness = 2
	separator.grow_begin = 5
	separator.grow_end = 5
	theme.set_stylebox("separator", "PopupMenu", separator)
	theme.set_stylebox("labeled_separator_left", "PopupMenu", separator)
	theme.set_stylebox("labeled_separator_right", "PopupMenu", separator)
	theme.set_color("font_color", "PopupMenu", INK)
	theme.set_color("font_hover_color", "PopupMenu", INK)
	theme.set_color("font_disabled_color", "PopupMenu", Color("999589"))
	theme.set_color("font_separator_color", "PopupMenu", MUTED)
	theme.set_font_size("font_size", "PopupMenu", 22)
	theme.set_font_size("font_separator_size", "PopupMenu", 19)
	theme.set_icon("checked", "PopupMenu", load("res://resources/bento_sketch/icons/checkbox_checked.svg"))
	theme.set_icon("unchecked", "PopupMenu", load("res://resources/bento_sketch/icons/checkbox_unchecked.svg"))
	theme.set_icon("radio_checked", "PopupMenu", load("res://resources/bento_sketch/icons/radio_checked.svg"))
	theme.set_icon("radio_unchecked", "PopupMenu", load("res://resources/bento_sketch/icons/radio_unchecked.svg"))
	theme.set_icon("submenu", "PopupMenu", load("res://resources/bento_sketch/icons/chevron_right.svg"))
	theme.set_icon("submenu_mirrored", "PopupMenu", load("res://resources/bento_sketch/icons/chevron_left.svg"))

	var menu_normal := _make_flat(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 9, Vector4(12, 7, 12, 8))
	var menu_hover := menu_normal.duplicate() as StyleBoxFlat
	menu_hover.bg_color = Color("f8e8b2")
	var menu_pressed := menu_normal.duplicate() as StyleBoxFlat
	menu_pressed.bg_color = WOOD
	for control_type in ["MenuButton", "MenuBar"]:
		theme.set_stylebox("normal", control_type, menu_normal)
		theme.set_stylebox("hover", control_type, menu_hover)
		theme.set_stylebox("pressed", control_type, menu_pressed)
		theme.set_stylebox("disabled", control_type, menu_normal)
		theme.set_color("font_color", control_type, INK)
		theme.set_color("font_hover_color", control_type, INK)
		theme.set_color("font_pressed_color", control_type, INK)
		theme.set_color("font_disabled_color", control_type, Color("999589"))
		theme.set_font_size("font_size", control_type, 22)
	theme.set_stylebox("focus", "MenuButton", tab_focus)


func _set_data_styles(theme: Theme) -> void:
	var panel := _make_flat(Color("fffef7"), INK, 3, 14, Vector4(8, 8, 8, 8))
	var focus := _make_flat(Color(0, 0, 0, 0), MUSTARD, 3, 15, Vector4(0, 0, 0, 0))
	var hover := _make_flat(Color("f8e8b2"), Color(0, 0, 0, 0), 0, 8, Vector4(8, 5, 8, 5))
	var selected := _make_flat(CORAL, INK, 2, 8, Vector4(8, 5, 8, 5))
	var cursor := _make_flat(Color(0, 0, 0, 0), MUSTARD, 2, 8, Vector4(0, 0, 0, 0))
	for control_type in ["ItemList", "Tree"]:
		theme.set_stylebox("panel", control_type, panel)
		theme.set_stylebox("focus", control_type, focus)
		theme.set_stylebox("hovered", control_type, hover)
		theme.set_stylebox("hovered_selected", control_type, selected)
		theme.set_stylebox("hovered_selected_focus", control_type, selected)
		theme.set_stylebox("selected", control_type, selected)
		theme.set_stylebox("selected_focus", control_type, selected)
		theme.set_stylebox("cursor", control_type, cursor)
		theme.set_stylebox("cursor_unfocused", control_type, cursor)
		theme.set_color("font_color", control_type, INK)
		theme.set_color("font_hovered_color", control_type, INK)
		theme.set_color("font_hovered_selected_color", control_type, Color.WHITE)
		theme.set_color("font_selected_color", control_type, Color.WHITE)
		theme.set_color("guide_color", control_type, Color("b7ae91"))
		theme.set_font_size("font_size", control_type, 21)
	theme.set_color("font_disabled_color", "Tree", Color("999589"))
	theme.set_icon("checked", "Tree", load("res://resources/bento_sketch/icons/checkbox_checked.svg"))
	theme.set_icon("unchecked", "Tree", load("res://resources/bento_sketch/icons/checkbox_unchecked.svg"))
	theme.set_icon("indeterminate", "Tree", load("res://resources/bento_sketch/icons/checkbox_indeterminate.svg"))
	theme.set_icon("arrow", "Tree", load("res://resources/bento_sketch/icons/chevron_down.svg"))
	theme.set_icon("arrow_collapsed", "Tree", load("res://resources/bento_sketch/icons/chevron_right.svg"))
	theme.set_icon("arrow_collapsed_mirrored", "Tree", load("res://resources/bento_sketch/icons/chevron_left.svg"))
	theme.set_icon("select_arrow", "Tree", load("res://resources/bento_sketch/icons/arrow_down.svg"))
	theme.set_stylebox("title_button_normal", "Tree", _make_flat(WOOD, INK, 2, 8, Vector4(8, 5, 8, 5)))
	theme.set_stylebox("title_button_hover", "Tree", _make_flat(Color("f8e8b2"), INK, 2, 8, Vector4(8, 5, 8, 5)))
	theme.set_stylebox("title_button_pressed", "Tree", selected)
	theme.set_color("title_button_color", "Tree", INK)
	theme.set_font_size("title_button_font_size", "Tree", 21)
	theme.set_constant("draw_guides", "Tree", 1)
	theme.set_constant("draw_relationship_lines", "Tree", 1)


func _set_scroll_styles(theme: Theme) -> void:
	var track := _make_flat(Color("ded9c6"), INK, 2, 6, Vector4(3, 3, 3, 3))
	var grabber := _make_flat(WOOD, INK, 2, 7, Vector4(4, 4, 4, 4))
	var grabber_hover := grabber.duplicate() as StyleBoxFlat
	grabber_hover.bg_color = Color("f1d57b")
	var grabber_pressed := grabber.duplicate() as StyleBoxFlat
	grabber_pressed.bg_color = CORAL
	var scroll_focus := _make_flat(Color(0, 0, 0, 0), MUSTARD, 2, 8, Vector4(0, 0, 0, 0))
	for control_type in ["HScrollBar", "VScrollBar"]:
		theme.set_stylebox("scroll", control_type, track)
		theme.set_stylebox("scroll_focus", control_type, scroll_focus)
		theme.set_stylebox("grabber", control_type, grabber)
		theme.set_stylebox("grabber_highlight", control_type, grabber_hover)
		theme.set_stylebox("grabber_pressed", control_type, grabber_pressed)
	var left := load("res://resources/bento_sketch/icons/chevron_left.svg") as Texture2D
	var right := load("res://resources/bento_sketch/icons/chevron_right.svg") as Texture2D
	var up := load("res://resources/bento_sketch/icons/chevron_up.svg") as Texture2D
	var down := load("res://resources/bento_sketch/icons/chevron_down.svg") as Texture2D
	for suffix in ["", "_highlight", "_pressed"]:
		theme.set_icon("decrement" + suffix, "HScrollBar", left)
		theme.set_icon("increment" + suffix, "HScrollBar", right)
		theme.set_icon("decrement" + suffix, "VScrollBar", up)
		theme.set_icon("increment" + suffix, "VScrollBar", down)

	for style_name in ["slider", "grabber_area", "grabber_area_highlight"]:
		theme.set_stylebox(style_name, "VSlider", theme.get_stylebox(style_name, "HSlider"))
	for icon_name in ["grabber", "grabber_highlight", "grabber_disabled"]:
		theme.set_icon(icon_name, "VSlider", theme.get_icon(icon_name, "HSlider"))

	theme.set_stylebox("panel", "ScrollContainer", _make_flat(Color("f7f3e4"), INK, 2, 12, Vector4(5, 5, 5, 5)))
	theme.set_stylebox("focus", "ScrollContainer", scroll_focus)
	theme.set_type_variation("BentoBareScroll", "ScrollContainer")
	theme.set_stylebox("panel", "BentoBareScroll", _make_flat(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 0, Vector4(0, 0, 0, 0)))
	theme.set_stylebox("focus", "BentoBareScroll", _make_flat(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 0, Vector4(0, 0, 0, 0)))

	var vertical_separator := StyleBoxLine.new()
	vertical_separator.color = INK
	vertical_separator.thickness = 3
	vertical_separator.vertical = true
	vertical_separator.grow_begin = 5
	vertical_separator.grow_end = 5
	theme.set_stylebox("separator", "VSeparator", vertical_separator)
	theme.set_constant("separation", "VSeparator", 14)


func _set_dialog_styles(theme: Theme) -> void:
	var border := _make_flat(PAPER, INK, 4, 20, Vector4(24, 24, 24, 24))
	border.shadow_color = Color(0.12, 0.11, 0.09, 0.28)
	border.shadow_size = 12
	border.shadow_offset = Vector2(5, 7)
	theme.set_stylebox("embedded_border", "Window", border)
	theme.set_stylebox("embedded_unfocused_border", "Window", border)
	theme.set_color("title_color", "Window", INK)
	theme.set_font_size("title_font_size", "Window", 28)
	theme.set_constant("title_height", "Window", 48)
	var close_icon := load("res://resources/bento_sketch/icons/close.svg") as Texture2D
	theme.set_icon("close", "Window", close_icon)
	theme.set_icon("close_pressed", "Window", close_icon)
	theme.set_stylebox("panel", "AcceptDialog", border)
	theme.set_constant("buttons_separation", "AcceptDialog", 12)

	theme.set_type_variation("BentoDialogPanel", "PanelContainer")
	theme.set_stylebox("panel", "BentoDialogPanel", border)


func _apply_button_set(theme: Theme, type_name: String, normal: StyleBox, hover: StyleBox, pressed: StyleBox, disabled: StyleBox, focus: StyleBox) -> void:
	theme.set_stylebox("normal", type_name, normal)
	theme.set_stylebox("hover", type_name, hover)
	theme.set_stylebox("pressed", type_name, pressed)
	theme.set_stylebox("hover_pressed", type_name, pressed)
	theme.set_stylebox("disabled", type_name, disabled)
	theme.set_stylebox("focus", type_name, focus)
	theme.set_color("font_color", type_name, INK)
	theme.set_color("font_hover_color", type_name, INK)
	theme.set_color("font_pressed_color", type_name, INK)
	theme.set_color("font_focus_color", type_name, INK)
	theme.set_color("font_disabled_color", type_name, Color("999589"))
	theme.set_font_size("font_size", type_name, 24)


func _make_flat(bg: Color, border: Color, border_width: int = 3, radius: int = 10, margins: Vector4 = Vector4(14, 10, 14, 10)) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius + 1
	style.corner_radius_top_right = max(radius - 1, 0)
	style.corner_radius_bottom_right = radius + 2
	style.corner_radius_bottom_left = max(radius - 2, 0)
	style.corner_detail = 8
	style.anti_aliasing = true
	style.content_margin_left = margins.x
	style.content_margin_top = margins.y
	style.content_margin_right = margins.z
	style.content_margin_bottom = margins.w
	return style


func _make_texture_box(texture: Texture2D, texture_margin: int, margins: Vector4) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = texture_margin
	style.texture_margin_top = texture_margin
	style.texture_margin_right = texture_margin
	style.texture_margin_bottom = texture_margin
	style.content_margin_left = margins.x
	style.content_margin_top = margins.y
	style.content_margin_right = margins.z
	style.content_margin_bottom = margins.w
	style.draw_center = true
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	return style
