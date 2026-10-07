extends Node

var recipes: Dictionary = {
	["ElbowGrease", "OilOfVitriol", "PhoenixFeather"]: {
		"name": "Potion of Mogging",
		"bottle_type": "Potion1",
		"frame": 1
	},
	["OilOfVitriol", "PhoenixFeather", "Wormwood"]: {
		"name": "Potion of Beautification",
		"bottle_type": "Potion1",
		"frame": 2
	},
	["ElbowGrease", "OilOfVitriol", "Stardust"]: {
		"name": "Potion of Rapid Shaking",
		"bottle_type": "Potion2",
		"frame": 1
	},
	["ElbowGrease", "EyeOfNewt", "PhoenixFeather"]: {
		"name": "Potion of Eye Colour Swap",
		"bottle_type": "Potion2",
		"frame": 2
	},
	["ElbowGrease", "EyeOfNewt", "Wormwood"]: {
		"name": "Potion of Permanent Smile",
		"bottle_type": "Potion3",
		"frame": 1
	},
	["EyeOfNewt", "PhoenixFeather", "Wormwood"]: {
		"name": "Potion of Green Skin",
		"bottle_type": "Potion3",
		"frame": 2
	},
	["ElbowGrease", "PhoenixFeather", "Wormwood"]: {
		"name": "Potion of Curing",
		"bottle_type": "Potion3",
		"frame": 3
	},
	["EyeOfNewt", "OilOfVitriol", "Wormwood"]: {
		"name": "Potion Of Baldness",
		"bottle_type": "Potion4",
		"frame": 1
	},
	["ElbowGrease", "OilOfVitriol", "Wormwood"]: {
		"name": "Potion of Head Size Increase",
		"bottle_type": "Potion4",
		"frame": 2
	},
	["ElbowGrease", "EyeOfNewt", "OilOfVitriol"]: {
		"name": "Potion of Head Size Decrease",
		"bottle_type": "Potion4",
		"frame": 3
	},
	["EyeOfNewt", "PhoenixFeather", "Stardust"]: {
		"name": "Potion of Creature Feature",
		"bottle_type": "Potion5",
		"frame": 1
	},
	["ElbowGrease", "Stardust", "Wormwood"]: {
		"name": "Potion of Rabies",
		"bottle_type": "Potion5",
		"frame": 2
	},
	["PhoenixFeather", "Stardust", "Wormwood"]: {
		"name": "Potion of Change Language",
		"bottle_type": "Potion1",
		"frame": 3
	},
	["EyeOfNewt", "Stardust", "Wormwood"]: {
		"name": "Potion of Change Art Styles",
		"bottle_type": "Potion2",
		"frame": 3
	},
	["ElbowGrease", "PhoenixFeather", "Stardust"]: {
		"name": "Potion of Body Swap",
		"bottle_type": "Potion3",
		"frame": 1
	},
	["ElbowGrease", "EyeOfNewt", "Stardust"]: {
		"name": "Potion of Love",
		"bottle_type": "Potion4",
		"frame": 1
	},
	["OilOfVitriol", "PhoenixFeather", "Stardust"]: {
		"name": "Potion of Explode",
		"bottle_type": "Potion5",
		"frame": 3
	},
	["EyeOfNewt", "OilOfVitriol", "PhoenixFeather"]: {
		"name": "Potion of Skeleton",
		"bottle_type": "Potion1",
		"frame": 1
	},
	["OilOfVitriol", "Stardust", "Wormwood"]: {
		"name": "Potion of Enlarge Person",
		"bottle_type": "Potion2",
		"frame": 2
	},
	["EyeOfNewt", "OilOfVitriol", "Stardust"]: {
		"name": "Potion of Shrink Person",
		"bottle_type": "Potion5",
		"frame": 2
	}
}


func get_potion_data(ingredients: Array) -> Dictionary:
	var sorted_ingredients = ingredients.duplicate()
	sorted_ingredients.sort()
	
	if recipes.has(sorted_ingredients):
		return recipes[sorted_ingredients]
		
	return {}


func get_potion_name(ingredients: Array) -> String:
	var data = get_potion_data(ingredients)
	return data.get("name", "")


func get_all_potion_types() -> Array[String]:
	var names: Array[String] = []
	for recipe_data in recipes.values():
		names.append(recipe_data["name"])
	return names
