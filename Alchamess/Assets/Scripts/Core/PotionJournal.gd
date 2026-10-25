extends Node

# potion_name -> Array of ingredient names (ALL potions, not just discovered)
var all_potion_ingredients: Dictionary = {}

# ingredient_name -> Array of ALL unique potion names that use it
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
	if PotionDatabase:
		initialize_recipes(PotionDatabase.recipes)


func initialize_recipes(recipes: Dictionary) -> void:
	if not all_potion_ingredients.is_empty():
		return

	all_potion_ingredients.clear()
	all_potions_by_ingredient.clear()

	for ingredients in recipes.keys():
		var raw_val = recipes[ingredients]
		var potion_name: String = ""
		
		if raw_val is Dictionary and raw_val.has("name"):
			potion_name = str(raw_val["name"])
		elif raw_val is String:
			potion_name = raw_val
		else:
			continue

		var ingredients_copy: Array = ingredients.duplicate()
		all_potion_ingredients[potion_name] = ingredients_copy

		for ingredient in ingredients_copy:
			var ing_str = str(ingredient).strip_edges()
			if not all_potions_by_ingredient.has(ing_str):
				all_potions_by_ingredient[ing_str] = []
			
			if not all_potions_by_ingredient[ing_str].has(potion_name):
				all_potions_by_ingredient[ing_str].append(potion_name)

	for ingredient in all_potions_by_ingredient.keys():
		all_potions_by_ingredient[ingredient].sort()

	journal_updated.emit()


func register_potion(potion_name: String, ingredients: Array = [], customer_name: String = "HerbBert") -> void:
	var target_customer: String = customer_name
	if target_customer.strip_edges().is_empty():
		target_customer = "HerbBert"

	if discovered_potions.has(potion_name):
		if potion_data.has(potion_name) and potion_data[potion_name].get("last_customer", "").strip_edges().is_empty():
			potion_data[potion_name]["last_customer"] = target_customer
		return

	discovered_potions[potion_name] = true

	var final_ingredients: Array = ingredients
	if final_ingredients.is_empty():
		final_ingredients = all_potion_ingredients.get(potion_name, [])
	elif not all_potion_ingredients.has(potion_name):
		all_potion_ingredients[potion_name] = final_ingredients.duplicate()

	potion_data[potion_name] = {
		"ingredients": final_ingredients.duplicate(),
		"notes": "",
		"last_customer": target_customer,
		"last_frame": 0
	}

	potion_discovered.emit(potion_name)
	potion_unlocked.emit(potion_name, discovered_potions.size())

	var current_total: int = discovered_potions.size()
	if current_total >= 4 and not has_made_four_potions:
		has_made_four_potions = true
		NewIngredientUnlocked.emit("PhoenixFeather")
		
	if current_total >= 10 and not has_made_ten_potions:
		has_made_ten_potions = true
		NewIngredientUnlocked.emit("Stardust")

	journal_updated.emit()


func get_unlocked_ingredients() -> Array[String]:
	var available: Array[String] = ["ElbowGrease", "OilOfVitriol", "Wormwood", "EyeOfNewt"]
	
	if has_made_four_potions:
		available.append("PhoenixFeather")
		
	if has_made_ten_potions:
		available.append("Stardust")
		
	return available


func record_potion_given(potion_name: String, customer_name: String, frame: int) -> void:
	var target_customer: String = customer_name
	if target_customer.strip_edges().is_empty():
		target_customer = "HerbBert"

	if not potion_data.has(potion_name):
		potion_data[potion_name] = {
			"ingredients": all_potion_ingredients.get(potion_name, []),
			"notes": "",
			"last_customer": target_customer,
			"last_frame": 0
		}
	else:
		potion_data[potion_name]["last_customer"] = target_customer
		potion_data[potion_name]["last_frame"] = frame

	journal_updated.emit()


func get_potion_customer(potion_name: String) -> String:
	var customer: String = potion_data.get(potion_name, {}).get("last_customer", "")
	return customer if not customer.strip_edges().is_empty() else "HerbBert"


func get_potion_customer_frame(potion_name: String) -> int:
	return potion_data.get(potion_name, {}).get("last_frame", 0)


func get_potions_for_ingredient(ingredient: String) -> Array:
	var result: Array = []
	var ing_key: String = ingredient.strip_edges()
	for potion_name in all_potions_by_ingredient.get(ing_key, []):
		if discovered_potions.has(potion_name):
			result.append(potion_name)
	return result


func get_all_potions_for_ingredient(ingredient: String) -> Array:
	return all_potions_by_ingredient.get(ingredient.strip_edges(), [])


func get_discovered_count_for_ingredient(ingredient: String) -> int:
	return get_potions_for_ingredient(ingredient).size()


func get_total_count_for_ingredient(ingredient: String) -> int:
	return all_potions_by_ingredient.get(ingredient.strip_edges(), []).size()


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


func unlock_potion(potion_name: String, ingredients: Array = [], customer_name: String = "HerbBert") -> void:
	if ingredients.is_empty():
		ingredients = all_potion_ingredients.get(potion_name, [])
	register_potion(potion_name, ingredients, customer_name)


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
			register_potion(potion_name, ingredients, "HerbBert")
			record_potion_given(potion_name, "HerbBert", 0)
