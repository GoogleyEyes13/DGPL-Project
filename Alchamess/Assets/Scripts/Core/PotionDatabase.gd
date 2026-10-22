class_name PotionDatabase
extends RefCounted

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

const RECIPES: Dictionary = {
	["ElbowGrease", "OilOfVitriol", "PhoenixFeather"]: {
		"name": "Potion of Mogging",
		"frame": 11,
		"suffix": "Mog",
		"bottle_anim": "Potion1",
		"bottle_frame": 1
	},
	["OilOfVitriol", "PhoenixFeather", "Wormwood"]: {
		"name": "Potion of Beautification",
		"frame": 9,
		"suffix": "Beautification",
		"bottle_anim": "Potion5",
		"bottle_frame": 3
	},
	["ElbowGrease", "OilOfVitriol", "Stardust"]: {
		"name": "Potion of Rapid Shaking",
		"frame": 0,
		"suffix": "Normal",
		"effect": "shake",
		"bottle_anim": "Potion1",
		"bottle_frame": 2
	},
	["ElbowGrease", "EyeOfNewt", "PhoenixFeather"]: {
		"name": "Potion of Eye Colour Swap",
		"frame": 5,
		"suffix": "Eyes",
		"bottle_anim": "Potion4",
		"bottle_frame": 3
	},
	["ElbowGrease", "EyeOfNewt", "Wormwood"]: {
		"name": "Potion of Permanent Smile",
		"frame": 13,
		"suffix": "Normal",
		"bottle_anim": "Potion3",
		"bottle_frame": 2
	},
	["EyeOfNewt", "PhoenixFeather", "Wormwood"]: {
		"name": "Potion of Green Skin",
		"frame": 4,
		"suffix": "Green",
		"bottle_anim": "Potion4",
		"bottle_frame": 1
	},
	["ElbowGrease", "PhoenixFeather", "Wormwood"]: {
		"name": "Potion of Curing",
		"frame": 0,
		"suffix": "Normal",
		"bottle_anim": "Potion3",
		"bottle_frame": 1
	},
	["EyeOfNewt", "OilOfVitriol", "Wormwood"]: {
		"name": "Potion of Baldness",
		"frame": 1,
		"suffix": "Bald",
		"bottle_anim": "Potion4",
		"bottle_frame": 2
	},
	["ElbowGrease", "OilOfVitriol", "Wormwood"]: {
		"name": "Potion of Head Size Increase",
		"frame": 2,
		"suffix": "BigHead",
		"bottle_anim": "Potion1",
		"bottle_frame": 3
	},
	["ElbowGrease", "EyeOfNewt", "OilOfVitriol"]: {
		"name": "Potion of Head Size Decrease",
		"frame": 3,
		"suffix": "SmallHead",
		"bottle_anim": "Potion1",
		"bottle_frame": 4
	},
	["EyeOfNewt", "PhoenixFeather", "Stardust"]: {
		"name": "Potion of Creature Feature",
		"frame": 8,
		"suffix": "TheFeaturedCreature",
		"scale": Vector2(0.20, 0.20),
		"bottle_anim": "Potion5",
		"bottle_frame": 2
	},
	["ElbowGrease", "Stardust", "Wormwood"]: {
		"name": "Potion of Rabies",
		"frame": 10,
		"suffix": "Rabies",
		"bottle_anim": "Potion5",
		"bottle_frame": 4
	},
	["PhoenixFeather", "Stardust", "Wormwood"]: {
		"name": "Potion of Change Language",
		"frame": 0,
		"suffix": "Normal",
		"bottle_anim": "Potion2",
		"bottle_frame": 4
	},
	["EyeOfNewt", "Stardust", "Wormwood"]: {
		"name": "Potion of Change Art Styles",
		"frame": 7,
		"suffix": "ArtStyleSwap",
		"bottle_anim": "Potion5",
		"bottle_frame": 1
	},
	["ElbowGrease", "PhoenixFeather", "Stardust"]: {
		"name": "Potion of Body Swap",
		"frame": 12,
		"suffix": "BodySwap",
		"bottle_anim": "Potion3",
		"bottle_frame": 3
	},
	["ElbowGrease", "EyeOfNewt", "Stardust"]: {
		"name": "Potion of Love",
		"frame": 0,
		"suffix": "Normal",
		"bottle_anim": "Potion3",
		"bottle_frame": 4
	},
	["OilOfVitriol", "PhoenixFeather", "Stardust"]: {
		"name": "Potion of Explode",
		"frame": 0,
		"suffix": "Skeleton",
		"effect": "explode",
		"bottle_anim": "Potion2",
		"bottle_frame": 3
	},
	["EyeOfNewt", "OilOfVitriol", "PhoenixFeather"]: {
		"name": "Potion of Skeleton",
		"frame": 6,
		"suffix": "Skeleton",
		"bottle_anim": "Potion4",
		"bottle_frame": 4
	},
	["OilOfVitriol", "Stardust", "Wormwood"]: {
		"name": "Potion of Enlarge Person",
		"frame": 0,
		"suffix": "BigHead",
		"scale": Vector2(0.14, 0.14),
		"bottle_anim": "Potion2",
		"bottle_frame": 1
	},
	["EyeOfNewt", "OilOfVitriol", "Stardust"]: {
		"name": "Potion of Shrink Person",
		"frame": 0,
		"suffix": "SmallHead",
		"scale": Vector2(0.05, 0.05),
		"shrink": true,
		"bottle_anim": "Potion2",
		"bottle_frame": 2
	}
}

# Compatibility alias for scripts reading PotionDatabase.recipes
static var recipes: Dictionary:
	get:
		return RECIPES

static var _by_name: Dictionary = {}

static func _ensure_name_cache() -> void:
	if _by_name.is_empty():
		for recipe_data in RECIPES.values():
			_by_name[recipe_data["name"]] = recipe_data

static func get_potion_data(ingredients: Array) -> Dictionary:
	var sorted_ingredients = ingredients.duplicate()
	sorted_ingredients.sort()
	
	if RECIPES.has(sorted_ingredients):
		return RECIPES[sorted_ingredients]
	
	for recipe_key in RECIPES.keys():
		var sorted_key = recipe_key.duplicate()
		sorted_key.sort()
		if sorted_key == sorted_ingredients:
			return RECIPES[recipe_key]
			
	return {}

static func get_potion_name(ingredients: Array) -> String:
	var data = get_potion_data(ingredients)
	return data.get("name", "")

static func get_all_potion_types() -> Array[String]:
	var names: Array[String] = []
	for recipe_data in RECIPES.values():
		names.append(recipe_data["name"])
	return names

static func get_potion_info_by_name(potion_name: String) -> Dictionary:
	_ensure_name_cache()
	return _by_name.get(potion_name, {})

static func get_ingredient_info(id: String) -> Dictionary:
	var key = id.strip_edges()
	return INGREDIENTS.get(key, {
		"display_name": key.capitalize(),
		"desc": "",
		"icon": "res://Assets/Ingredients/%s.png" % key
	})

static func get_ingredient_display_name(id: String) -> String:
	return get_ingredient_info(id).get("display_name", id)

static func get_all_ingredient_names() -> Array:
	return INGREDIENTS.keys()
