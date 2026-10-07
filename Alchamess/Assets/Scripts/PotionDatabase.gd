extends Node

var recipes: Dictionary = {
	["ElbowGrease", "OilOfVitriol", "PhoenixFeather"]: {
		"name": "Potion of Mogging"
	},
	["OilOfVitriol", "PhoenixFeather", "Wormwood"]: {
		"name": "Potion of Beautification"
	},
	["ElbowGrease", "OilOfVitriol", "Stardust"]: {
		"name": "Potion of Rapid Shaking"
	},
	["ElbowGrease", "EyeOfNewt", "PhoenixFeather"]: {
		"name": "Potion of Eye Colour Swap"
	},
	["ElbowGrease", "EyeOfNewt", "Wormwood"]: {
		"name": "Potion of Permanent Smile"
	},
	["EyeOfNewt", "PhoenixFeather", "Wormwood"]: {
		"name": "Potion of Green Skin"
	},
	["ElbowGrease", "PhoenixFeather", "Wormwood"]: {
		"name": "Potion of Curing"
	},
	["EyeOfNewt", "OilOfVitriol", "Wormwood"]: {
		"name": "Potion Of Baldness"
	},
	["ElbowGrease", "OilOfVitriol", "Wormwood"]: {
		"name": "Potion of Head Size Increase"
	},
	["ElbowGrease", "EyeOfNewt", "OilOfVitriol"]: {
		"name": "Potion of Head Size Decrease"
	},
	["EyeOfNewt", "PhoenixFeather", "Stardust"]: {
		"name": "Potion of Creature Feature"
	},
	["ElbowGrease", "Stardust", "Wormwood"]: {
		"name": "Potion of Rabies"
	},
	["PhoenixFeather", "Stardust", "Wormwood"]: {
		"name": "Potion of Change Language"
	},
	["EyeOfNewt", "Stardust", "Wormwood"]: {
		"name": "Potion of Change Art Styles"
	},
	["ElbowGrease", "PhoenixFeather", "Stardust"]: {
		"name": "Potion of Body Swap"
	},
	["ElbowGrease", "EyeOfNewt", "Stardust"]: {
		"name": "Potion of Love"
	},
	["OilOfVitriol", "PhoenixFeather", "Stardust"]: {
		"name": "Potion of Explode"
	},
	["EyeOfNewt", "OilOfVitriol", "PhoenixFeather"]: {
		"name": "Potion of Skeleton"
	},
	["OilOfVitriol", "Stardust", "Wormwood"]: {
		"name": "Potion of Enlarge Person"
	},
	["EyeOfNewt", "OilOfVitriol", "Stardust"]: {
		"name": "Potion of Shrink Person"
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
