extends TextureProgressBar
class_name RadialDial

@onready var center_label: Label = get_node_or_null("CenterLabel")

var tween: Tween

# Property aliases so existing code (like dial.max_count = ...) works seamlessly
var max_count: int:
	get:
		return int(max_value)
	set(val):
		set_max_count(val)

var count: int:
	get:
		return int(value)
	set(val):
		update_count(val, false)


func set_max_count(max_val: int) -> void:
	max_value = float(max_val if max_val > 0 else 1)
	_update_center_label()


func update_count(current_val: int, animate: bool = true) -> void:
	if tween and tween.is_running():
		tween.kill()

	var target: float = clampf(float(current_val), min_value, max_value)

	if animate and is_inside_tree():
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "value", target, 0.35)
		if center_label:
			tween.parallel().tween_method(_animate_label_number, int(value), int(target), 0.35)
	else:
		value = target
		_update_center_label()


func _animate_label_number(val: int) -> void:
	if center_label:
		center_label.text = str(val)


func _update_center_label() -> void:
	if center_label:
		center_label.text = str(int(value))
