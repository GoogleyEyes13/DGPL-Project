extends Area2D

var start_pos:  Vector2
var centre_pos:  Vector2
var end_pos:  Vector2
var cust_is_ready: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var window_size = get_viewport_rect().size
	
	start_pos = Vector2(window_size.x + 200, window_size.y / 2);
	centre_pos = Vector2(window_size.x / 2, window_size.y / 2);
	end_pos = Vector2(-200, window_size.y / 2)

	global_position = start_pos;
	hide()
	
	bob_in()

func bob_in():
	show()
	var tween = create_tween()
	tween.tween_property(self, "global_position", centre_pos, 1.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_callback(on_arrival)
	
	
func on_arrival():
	print("Customer is at the counter! Waiting for interaction...")
	cust_is_ready = true
	
func receive_potion(potion_type: String):
	if not cust_is_ready:
		return
		
		cust_is_ready = false
		
		#change animation frame to updated visual
		#INSERT HERE
		var delay = create_tween()
		delay.tween_interval(1.0)
		delay.tween_callback(bob_out)	
		
func bob_out():
	var tween = create_tween()
	tween.tween_property(self, "global_position", end_pos, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)
