extends Node

# potion_name -> Array of ingredient names (ALL potions, not just discovered)
var all_potion_ingredients: Dictionary = {}

# ingredient_name -> Array of ALL potion names that use it (fixed order once built)
var all_potions_by_ingredient: Dictionary = {}

# potion_name -> true once discovered
var discovered_potions: Dictionary = {}

# potion_name -> { "ingredients": Array, "notes": String, "last_customer": String, "last_frame": int }
var potion_data: Dictionary = {}

signal potion_discovered(potion_name: String)
signal journal_updated

func initialize_recipes(recipes: Dictionary) -> void:
	if not all_potion_ingredients.is_empty():
		return
	
	for ingredients in recipes.keys():
		var potion_name = recipes[ingredients]
		var ingredients_copy: Array = ingredients.duplicate()
		all_potion_ingredients[potion_name] = ingredients_copy
		
		for ingredient in ingredients_copy:
			if not all_potions_by_ingredient.has(ingredient):
				all_potions_by_ingredient[ingredient] = []
			all_potions_by_ingredient[ingredient].append(potion_name)
	
	for ingredient in all_potions_by_ingredient.keys():
		all_potions_by_ingredient[ingredient].sort()
	
	journal_updated.emit()

func register_potion(potion_name: String, ingredients: Array) -> void:
	if not discovered_potions.has(potion_name):
		discovered_potions[potion_name] = true
		potion_data[potion_name] = {
			"ingredients": ingredients.duplicate(),
			"notes": "",
			"last_customer": "",
			"last_frame": 0
		}
		potion_discovered.emit(potion_name)
	
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

func get_potions_for_ingredient(ingredient: String) -> Array:
	return all_potions_by_ingredient.get(ingredient, [])

func get_discovered_count_for_ingredient(ingredient: String) -> int:
	var count = 0
	for potion_name in get_potions_for_ingredient(ingredient):
		if discovered_potions.has(potion_name):
			count += 1
	return count

func get_total_count_for_ingredient(ingredient: String) -> int:
	return get_potions_for_ingredient(ingredient).size()

func get_total_discovered_count() -> int:
	return discovered_potions.size()

func get_total_potion_count() -> int:
	return all_potion_ingredients.size()

func is_potion_discovered(potion_name: String) -> bool:
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

func unlock_all_potions(recipes: Dictionary) -> void:
	initialize_recipes(recipes)
	for ingredients in recipes.keys():
		var potion_name = recipes[ingredients]
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
