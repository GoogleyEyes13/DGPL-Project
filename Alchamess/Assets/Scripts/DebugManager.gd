extends Node

@export var debug_enabled: bool = false

var current_customer: Node = null

func debug_log(message: String) -> void:
	if debug_enabled:
		print("[DEBUG] ", message)

func register_customer(customer_node: Node) -> void:
	current_customer = customer_node
	debug_log("Customer registered: " + customer_node.name)

func toggle_debug() -> void:
	debug_enabled = not debug_enabled
	debug_log("Debug logging: " + str(debug_enabled))

func trigger_potion(potion_type: String) -> void:
	if current_customer and current_customer.has_method("receive_potion"):
		debug_log("Manually triggering: " + potion_type)
		current_customer.receive_potion(potion_type)
	else:
		print("[DEBUG] No customer registered to trigger potion on!")
