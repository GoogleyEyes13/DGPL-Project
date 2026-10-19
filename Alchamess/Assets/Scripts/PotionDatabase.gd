extends Node

const INGREDIENTS: Dictionary = {
	"ElbowGrease": {
		"display_name": "Elbow Grease",
		"desc": "Pure, condensed physical labor. Clouded and dense.",
		"icon": "res://Assets/Ingredients/ElbowGrease.png"
	},
	"OilOfVitriol": {
		"display_name": "Oil Of Vitriol",
		"desc": "Corrosive and volatile. Strips away extraneous features.",
		"icon": "res://Assets/Ingredients/OilOfVitriol.png"
	},
	"PhoenixFeather": {
		"display_name": "Phoenix Feather",
		"desc": "Radiates eternal warmth. Essential for restorative draughts.",
		"icon": "res://Assets/Ingredients/PhoenixFeather.png"
	},
	"Wormwood": {
		"display_name": "Wormwood",
		"desc": "Bitter perennial herb. Calms nerves and fixes stubborn mixtures.",
		"icon": "res://Assets/Ingredients/Wormwood.png"
	},
	"EyeOfNewt": {
		"display_name": "Eye Of Newt",
		"desc": "Pickled amphibian oculars. Known to alter vision and forms.",
		"icon": "res://Assets/Ingredients/EyeOfNewt.png"
	},
	"Stardust": {
		"display_name": "Stardust",
		"desc": "Glinting cosmic residue. Unlocks strange celestial mutations.",
		"icon": "res://Assets/Ingredients/Stardust.png"
	}
}

var recipes: Dictionary = {
	["ElbowGrease", "OilOfVitriol", "PhoenixFeather"]: {
		"name": "Potion of Mogging",
		"frame": 11,
		"suffix": "Mog"
	},
	["OilOfVitriol", "PhoenixFeather", "Wormwood"]: {
		"name": "Potion of Beautification",
		"frame": 9,
		"suffix": "Beautification"
	},
	["ElbowGrease", "OilOfVitriol", "Stardust"]: {
		"name": "Potion of Rapid Shaking",
		"frame": 0,
		"suffix": "Normal",
		"effect": "shake"
	},
	["ElbowGrease", "EyeOfNewt", "PhoenixFeather"]: {
		"name": "Potion of Eye Colour Swap",
		"frame": 5,
		"suffix": "BlueEyes"
	},
	["ElbowGrease", "EyeOfNewt", "Wormwood"]: {
		"name": "Potion of Permanent Smile",
		"frame": 0,
		"suffix": "Normal"
	},
	["EyeOfNewt", "PhoenixFeather", "Wormwood"]: {
		"name": "Potion of Green Skin",
		"frame": 4,
		"suffix": "Green"
	},
	["ElbowGrease", "PhoenixFeather", "Wormwood"]: {
		"name": "Potion of Curing",
		"frame": 0,
		"suffix": "Normal"
	},
	["EyeOfNewt", "OilOfVitriol", "Wormwood"]: {
		"name": "Potion of Baldness",
		"frame": 1,
		"suffix": "Bald"
	},
	["ElbowGrease", "OilOfVitriol", "Wormwood"]: {
		"name": "Potion of Head Size Increase",
		"frame": 2,
		"suffix": "BigHead"
	},
	["ElbowGrease", "EyeOfNewt", "OilOfVitriol"]: {
		"name": "Potion of Head Size Decrease",
		"frame": 3,
		"suffix": "SmallHead"
	},
	["EyeOfNewt", "PhoenixFeather", "Stardust"]: {
		"name": "Potion of Creature Feature",
		"frame": 8,
		"suffix": "TheFeaturedCreature",
		"scale": Vector2(0.14, 0.14)
	},
	["ElbowGrease", "Stardust", "Wormwood"]: {
		"name": "Potion of Rabies",
		"frame": 10,
		"suffix": "Rabies"
	},
	["PhoenixFeather", "Stardust", "Wormwood"]: {
		"name": "Potion of Change Language",
		"frame": 0,
		"suffix": "Normal"
	},
	["EyeOfNewt", "Stardust", "Wormwood"]: {
		"name": "Potion of Change Art Styles",
		"frame": 7,
		"suffix": "ArtStyleSwap"
	},
	["ElbowGrease", "PhoenixFeather", "Stardust"]: {
		"name": "Potion of Body Swap",
		"frame": 12,
		"suffix": "BodySwap"
	},
	["ElbowGrease", "EyeOfNewt", "Stardust"]: {
		"name": "Potion of Love",
		"frame": 0,
		"suffix": "Normal"
	},
	["OilOfVitriol", "PhoenixFeather", "Stardust"]: {
		"name": "Potion of Explode",
		"frame": 0,
		"suffix": "Skeleton",
		"effect": "explode"
	},
	["EyeOfNewt", "OilOfVitriol", "PhoenixFeather"]: {
		"name": "Potion of Skeleton",
		"frame": 6,
		"suffix": "Skeleton"
	},
	["OilOfVitriol", "Stardust", "Wormwood"]: {
		"name": "Potion of Enlarge Person",
		"frame": 0,
		"suffix": "BigHead",
		"scale": Vector2(0.14, 0.14)
	},
	["EyeOfNewt", "OilOfVitriol", "Stardust"]: {
		"name": "Potion of Shrink Person",
		"frame": 0,
		"suffix": "SmallHead",
		"scale": Vector2(0.05, 0.05),
		"shrink": true
	}
}

var _by_name: Dictionary = {}

func _ready() -> void:
	_build_name_cache()

func _build_name_cache() -> void:
	_by_name.clear()
	for recipe_data in recipes.values():
		_by_name[recipe_data["name"]] = recipe_data

func get_potion_data(ingredients: Array) -> Dictionary:
	var sorted_ingredients = ingredients.duplicate()
	sorted_ingredients.sort()
	
	if recipes.has(sorted_ingredients):
		return recipes[sorted_ingredients]
	
	for recipe_key in recipes.keys():
		var sorted_key = recipe_key.duplicate()
		sorted_key.sort()
		if sorted_key == sorted_ingredients:
			return recipes[recipe_key]
			
	return {}

func get_potion_name(ingredients: Array) -> String:
	var data = get_potion_data(ingredients)
	return data.get("name", "")

func get_all_potion_types() -> Array[String]:
	var names: Array[String] = []
	for recipe_data in recipes.values():
		names.append(recipe_data["name"])
	return names

func get_potion_info_by_name(potion_name: String) -> Dictionary:
	if _by_name.is_empty():
		_build_name_cache()
	return _by_name.get(potion_name, {})

func get_ingredient_info(id: String) -> Dictionary:
	var key = id.strip_edges()
	return INGREDIENTS.get(key, {
		"display_name": key.capitalize(),
		"desc": "",
		"icon": "res://Assets/Ingredients/%s.png" % key
	})

func get_ingredient_display_name(id: String) -> String:
	return get_ingredient_info(id).get("display_name", id)

func get_all_ingredient_names() -> Array:
	return INGREDIENTS.keys()
