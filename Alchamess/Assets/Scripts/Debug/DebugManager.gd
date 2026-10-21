extends Node

@export var debug_enabled: bool = false
var skip_dialogue: bool = false

var current_customer: Node = null
var current_cauldron: Node = null

signal log_message(message: String)

func debug_log(message: String) -> void:
	if debug_enabled:
		print("[DEBUG] ", message)
		log_message.emit(message)

func register_customer(customer_node: Node) -> void:
	current_customer = customer_node
	debug_log("Customer registered: " + customer_node.name)

func register_cauldron(cauldron_node: Node) -> void:
	current_cauldron = cauldron_node
	debug_log("Cauldron registered: " + cauldron_node.name)

func toggle_debug() -> void:
	debug_enabled = not debug_enabled
	debug_log("Debug logging: " + str(debug_enabled))

func toggle_skip_dialogue(enabled: bool) -> void:
	skip_dialogue = enabled
	debug_log("Skip Dialogue: " + str(skip_dialogue))

func trigger_potion(potion_type: String) -> void:
	# 1. Fetch ingredients directly from PotionDatabase recipes
	var ingredients: Array = []
	for recipe_ingredients in PotionDatabase.RECIPES.keys():
		if PotionDatabase.RECIPES[recipe_ingredients]["name"] == potion_type:
			ingredients = recipe_ingredients.duplicate()
			break

	# 2. Register potion into PotionJournal with full recipe data
	if PotionJournal:
		PotionJournal.register_potion(potion_type, ingredients)
		
		# Immediately associate the customer to prevent fallback before animation finishes
		if current_customer and "CustomerName" in current_customer:
			var info: Dictionary = PotionDatabase.get_potion_info_by_name(potion_type)
			var target_frame: int = info.get("frame", 0)
			PotionJournal.record_potion_given(potion_type, current_customer.CustomerName, target_frame)
		
		debug_log("Registered potion in book: " + potion_type)

	# 3. Increment Cauldron ingredient usage & notify dials
	var cauldron = current_cauldron if current_cauldron else get_node_or_null("/root/Game/WitchCauldron")
	if cauldron and "ingredient_usage_counts" in cauldron:
		for ing in ingredients:
			if cauldron.ingredient_usage_counts.has(ing):
				cauldron.ingredient_usage_counts[ing] += 1
		if cauldron.has_signal("ingredient_counts_updated"):
			cauldron.ingredient_counts_updated.emit(cauldron.ingredient_usage_counts)

	# 4. Hand to customer (plays visuals, dialogue, and animations)
	if current_customer and current_customer.has_method("receive_potion"):
		debug_log("Manually triggering on customer: " + potion_type)
		current_customer.receive_potion(potion_type)
	else:
		print("[DEBUG] No customer registered to trigger potion on!")
