extends Node

# ingredient_name: Array of potion names discovered that use it
var discovered_by_ingredient: Dictionary = {}

var potion_data: Dictionary = {}

signal potion_discovered(potion_name: String)

func register_potion(potion_name: String, ingredients: Array) -> void:
	if potion_data.has(potion_name):
		return  # already discovered, don't overwrite
	
	potion_data[potion_name] = {
		"ingredients": ingredients.duplicate(),
		"notes": ""
	}
	
	for ingredient in ingredients:
		if not discovered_by_ingredient.has(ingredient):
			discovered_by_ingredient[ingredient] = []
		if not discovered_by_ingredient[ingredient].has(potion_name):
			discovered_by_ingredient[ingredient].append(potion_name)
	
	potion_discovered.emit(potion_name)

func get_potions_for_ingredient(ingredient: String) -> Array:
	return discovered_by_ingredient.get(ingredient, [])

func get_ingredients_for_potion(potion_name: String) -> Array:
	return potion_data.get(potion_name, {}).get("ingredients", [])

func set_note(potion_name: String, note: String) -> void:
	if potion_data.has(potion_name):
		potion_data[potion_name]["notes"] = note

func get_note(potion_name: String) -> String:
	return potion_data.get(potion_name, {}).get("notes", "")
