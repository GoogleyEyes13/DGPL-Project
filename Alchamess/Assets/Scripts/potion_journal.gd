extends Node

# potion_name -> Array of ingredient names (ALL potions, not just discovered)
var all_potion_ingredients: Dictionary = {}

# ingredient_name -> Array of ALL potion names that use it (fixed order once built)
var all_potions_by_ingredient: Dictionary = {}

# potion_name -> true once discovered
var discovered_potions: Dictionary = {}
var has_made_four_potions: bool = false
var has_made_ten_potions: bool = false

signal NewIngredientUnlocked(IngredientName)
signal potion_unlocked(potion_name: String, total_unlocked: int)
signal potion_discovered(potion_name: String)
signal journal_updated

# potion_name -> { "ingredients": Array, "notes": String, "last_customer": String, "last_frame": int }
var potion_data: Dictionary = {}

func _ready() -> void:
	# Automatically populate recipes if PotionDatabase exists
	if Engine.has_singleton("PotionDatabase") or get_node_or_null("/root/PotionDatabase"):
		var db = get_node("/root/PotionDatabase")
		if "recipes" in db:
			initialize_recipes(db.recipes)
		elif db.has_method("get_all_recipes"):
			initialize_recipes(db.get_all_recipes())

func initialize_recipes(recipes: Dictionary) -> void:
	if not all_potion_ingredients.is_empty():
		return

	all_potion_ingredients.clear()
	all_potions_by_ingredient.clear()

	for ingredients in recipes.keys():
		var raw_val = recipes[ingredients]
		var potion_name: String = ""
		
		# Handles both { "name": "Potion Name" } and "Potion Name"
		if raw_val is Dictionary and raw_val.has("name"):
			potion_name = str(raw_val["name"])
		elif raw_val is String:
			potion_name = raw_val
		else:
			continue

		var ingredients_copy: Array = ingredients.duplicate()
		all_potion_ingredients[potion_name] = ingredients_copy

		for ingredient in ingredients_copy:
			if not all_potions_by_ingredient.has(ingredient):
				all_potions_by_ingredient[ingredient] = []
			
			if not all_potions_by_ingredient[ingredient].has(potion_name):
				all_potions_by_ingredient[ingredient].append(potion_name)

	for ingredient in all_potions_by_ingredient.keys():
		all_potions_by_ingredient[ingredient].sort()

	journal_updated.emit()

func register_potion(potion_name: String, ingredients: Array = []) -> void:
	var is_new: bool = false

	# Ensure the potion exists in the master ingredients lookup
	if not all_potion_ingredients.has(potion_name):
		if not ingredients.is_empty():
			all_potion_ingredients[potion_name] = ingredients.duplicate()
			for ing in ingredients:
				if not all_potions_by_ingredient.has(ing):
					all_potions_by_ingredient[ing] = []
				if not all_potions_by_ingredient[ing].has(potion_name):
					all_potions_by_ingredient[ing].append(potion_name)
					all_potions_by_ingredient[ing].sort()

	if not discovered_potions.has(potion_name):
		discovered_potions[potion_name] = true
		
		var final_ingredients: Array = ingredients
		if final_ingredients.is_empty():
			final_ingredients = all_potion_ingredients.get(potion_name, [])

		potion_data[potion_name] = {
			"ingredients": final_ingredients.duplicate(),
			"notes": "",
			"last_customer": "",
			"last_frame": 0
		}
		is_new = true
		potion_discovered.emit(potion_name)
		potion_unlocked.emit(potion_name, discovered_potions.size())

	# Milestones
	if discovered_potions.size() == 4 and not has_made_four_potions:
		has_made_four_potions = true
		NewIngredientUnlocked.emit("PhoenixFeather")
	elif discovered_potions.size() == 10 and not has_made_ten_potions:
		has_made_ten_potions = true
		NewIngredientUnlocked.emit("Stardust")

	if is_new:
		journal_updated.emit()

func record_potion_given(potion_name: String, customer_name: String, frame: int) -> void:
	if not potion_data.has(potion_name):
		potion_data[potion_name] = {
			"ingredients": all_potion_ingredients.get(potion_name, []),
			"notes": "",
			"last_customer": "",
			"last_frame": 0
		}
	potion_data[potion_name]["last_customer"] = customer_name
	potion_data[potion_name]["last_frame"] = frame
	journal_updated.emit()

func get_potion_customer(potion_name: String) -> String:
	return potion_data.get(potion_name, {}).get("last_customer", "")

func get_potion_customer_frame(potion_name: String) -> int:
	return potion_data.get(potion_name, {}).get("last_frame", 0)

# Returns all discovered potions that contain this ingredient
func get_potions_for_ingredient(ingredient: String) -> Array:
	var result: Array = []
	var all_potions: Array = all_potions_by_ingredient.get(ingredient, [])
	for potion_name in all_potions:
		if discovered_potions.has(potion_name):
			result.append(potion_name)
	return result

# Returns all potions that use this ingredient (discovered or not)
func get_all_potions_for_ingredient(ingredient: String) -> Array:
	return all_potions_by_ingredient.get(ingredient, [])

func get_discovered_count_for_ingredient(ingredient: String) -> int:
	return get_potions_for_ingredient(ingredient).size()

func get_total_count_for_ingredient(ingredient: String) -> int:
	return all_potions_by_ingredient.get(ingredient, []).size()

func get_total_discovered_count() -> int:
	return discovered_potions.size()

func get_unlocked_count() -> int:
	return discovered_potions.size()

func get_total_potion_count() -> int:
	return all_potion_ingredients.size()

func get_total_possible_potions() -> int:
	return all_potion_ingredients.size()

func is_potion_discovered(potion_name: String) -> bool:
	return discovered_potions.has(potion_name)

func is_potion_unlocked(potion_name: String) -> bool:
	return discovered_potions.has(potion_name)

func get_ingredients_for_potion(potion_name: String) -> Array:
	if potion_data.has(potion_name):
		return potion_data[potion_name]["ingredients"]
	return all_potion_ingredients.get(potion_name, [])

func set_note(potion_name: String, note: String) -> void:
	if potion_data.has(potion_name):
		potion_data[potion_name]["notes"] = note

func get_note(potion_name: String) -> String:
	return potion_data.get(potion_name, {}).get("notes", "")

func unlock_potion(potion_name: String, ingredients: Array = []) -> void:
	if ingredients.is_empty():
		ingredients = all_potion_ingredients.get(potion_name, [])
	register_potion(potion_name, ingredients)

func unlock_all_potions(recipes: Dictionary) -> void:
	if all_potion_ingredients.is_empty():
		initialize_recipes(recipes)
		
	for ingredients in recipes.keys():
		var raw_val = recipes[ingredients]
		var potion_name: String = ""
		if raw_val is Dictionary and raw_val.has("name"):
			potion_name = str(raw_val["name"])
		elif raw_val is String:
			potion_name = raw_val
		
		if not potion_name.is_empty():
			register_potion(potion_name, ingredients)

static func build_progress_dots(discovered: int, total: int, dot_size: float = 8.0) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 3)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	for i in total:
		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(dot_size, dot_size)
		dot.color = Color(0.95, 0.78, 0.2) if i < discovered else Color(0.35, 0.35, 0.35, 0.6)
		row.add_child(dot)
	return row
