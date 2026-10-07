extends Sprite2D

var has_logged_mix_finished: bool = false
var CauldronIngredients: Dictionary = {}

var PotionRecipes: Dictionary = {
	["ElbowGrease", "OilOfVitriol", "PhoenixFeather"]: "Potion of Mogging",
	["OilOfVitriol", "PhoenixFeather", "Wormwood"]: "Potion of Beautification",
	["ElbowGrease", "OilOfVitriol", "Stardust"]: "Potion of Rapid Shaking",
	["ElbowGrease", "EyeOfNewt", "PhoenixFeather"]: "Potion of Eye Colour Swap",
	["ElbowGrease", "EyeOfNewt", "Wormwood"]: "Potion of Permanent Smile",
	["EyeOfNewt", "PhoenixFeather", "Wormwood"]: "Potion of Green Skin",
	["ElbowGrease", "PhoenixFeather", "Wormwood"]: "Potion of Curing",
	["EyeOfNewt", "OilOfVitriol", "Wormwood"]: "Potion Of Baldness",
	["ElbowGrease", "OilOfVitriol", "Wormwood"]: "Potion of Head Size Increase",
	["ElbowGrease", "EyeOfNewt", "OilOfVitriol"]: "Potion of Head Size Decrease",
	["EyeOfNewt", "PhoenixFeather", "Stardust"]: "Potion of Creature Feature",
	["ElbowGrease", "Stardust", "Wormwood"]: "Potion of Rabies",
	["PhoenixFeather", "Stardust", "Wormwood"]: "Potion of Change Language",
	["EyeOfNewt", "Stardust", "Wormwood"]: "Potion of Change Art Styles",
	["ElbowGrease", "PhoenixFeather", "Stardust"]: "Potion of Body Swap",
	["ElbowGrease", "EyeOfNewt", "Stardust"]: "Potion of Love",
	["OilOfVitriol", "PhoenixFeather", "Stardust"]: "Potion of Explode",
	["EyeOfNewt", "OilOfVitriol", "PhoenixFeather"]: "Potion of Skeleton",
	["OilOfVitriol", "Stardust", "Wormwood"]: "Potion of Enlarge Person",
	["EyeOfNewt", "OilOfVitriol", "Stardust"]: "Potion of Shrink Person"
}

var ingredient_usage_counts: Dictionary = {
	"ElbowGrease": 0,
	"EyeOfNewt": 0,
	"OilOfVitriol": 0,
	"PhoenixFeather": 0,
	"Stardust": 0,
	"Wormwood": 0
}

@onready var MixingStick = $"../MixingStick"
@onready var CauldronFull: bool = false

signal ingredients_updated(ingredients: Array, last_potion: String)
signal potion_bottle_filled(bottle_type: String, potion_name: String)
signal ingredient_counts_updated(counts: Dictionary)

var LastPotionCreated: String = "None"
var PotionMixed: bool = false

var in_pot_sounds: Dictionary = {
	"ElbowGrease": preload("res://Assets/Audio/SFX/Ingredients in Pot/elbow grease.wav"),
	"EyeOfNewt": preload("res://Assets/Audio/SFX/Ingredients in Pot/eye of newt.wav"),
	"OilOfVitriol": preload("res://Assets/Audio/SFX/Ingredients in Pot/oil of vitriol.wav"),
	"PhoenixFeather": preload("res://Assets/Audio/SFX/Ingredients in Pot/phoenix feather.wav"),
	"Stardust": preload("res://Assets/Audio/SFX/Ingredients in Pot/stardust.wav"),
	"Wormwood": preload("res://Assets/Audio/SFX/Ingredients in Pot/wormwood.wav"),
}

@onready var in_pot_sfx: AudioStreamPlayer = $InPotSFX
@onready var area_2d: Area2D = $Area2D


func _ready() -> void:
	MixingStick.potion_mixed.connect(_on_potion_mixed)
	
	if area_2d:
		if not area_2d.body_entered.is_connected(_on_collision_entered):
			area_2d.body_entered.connect(_on_collision_entered)
		if not area_2d.area_entered.is_connected(_on_collision_entered):
			area_2d.area_entered.connect(_on_collision_entered)


func _add_ingredient_to_cauldron(ingredient_name: String) -> bool:
	if CauldronIngredients.size() >= 3:
		DebugManager.debug_log("Cauldron full")
		return false
	
	if CauldronIngredients.has(ingredient_name):
		DebugManager.debug_log(ingredient_name + " is already in the pot")
		return false
	
	CauldronIngredients[ingredient_name] = 1
	DebugManager.debug_log(ingredient_name + " has been placed in the pot")
	
	if in_pot_sounds.has(ingredient_name):
		in_pot_sfx.stream = in_pot_sounds[ingredient_name]
		in_pot_sfx.play()
	
	ingredients_updated.emit(CauldronIngredients.keys(), LastPotionCreated)
	
	if CauldronIngredients.size() == 3:
		CauldronFull = true
		ingredients_updated.emit(CauldronIngredients.keys(), LastPotionCreated)
		MixingStick.start_mixing()
		
	return true


func _on_collision_entered(incoming_node: Node2D) -> void:
	var target_node: Node2D = incoming_node
	
	if "ingredientType" not in target_node and "potionName" not in target_node and incoming_node.get_parent() != null:
		target_node = incoming_node.get_parent()

	# 1. Detect Ingredient
	if "ingredientType" in target_node and target_node.ingredientType != "":
		var ingredient_name: String = target_node.ingredientType
		
		if _add_ingredient_to_cauldron(ingredient_name):
			if target_node.has_method("drop"):
				target_node.drop()
			else:
				target_node.queue_free()
		return

	# 2. Detect Potion Bottle
	if target_node is PotionBottle or "potionName" in target_node:
		DebugManager.debug_log("Potion bottle detected in cauldron")
		
		if CauldronFull and PotionMixed:
			var ingredients_list: Array = CauldronIngredients.keys()
			ingredients_list.sort()
			
			if PotionRecipes.has(ingredients_list):
				var potion_name: String = PotionRecipes[ingredients_list]
				LastPotionCreated = potion_name
				
				# Increment usage count for each ingredient in this crafted potion
				for ingredient in ingredients_list:
					if ingredient_usage_counts.has(ingredient):
						ingredient_usage_counts[ingredient] += 1
				
				ingredient_counts_updated.emit(ingredient_usage_counts)
				
				if target_node.has_method("fill_bottle"):
					target_node.fill_bottle(LastPotionCreated)
				
				potion_bottle_filled.emit(target_node.potionName, LastPotionCreated)
				
				# Reset state
				MixingStick.reset_liquid_colour()
				PotionMixed = false
				CauldronFull = false
				CauldronIngredients = {}
				has_logged_mix_finished = false
				
				ingredients_updated.emit(CauldronIngredients.keys(), LastPotionCreated)
				PotionJournal.register_potion(potion_name, ingredients_list)


func _on_potion_mixed() -> void:
	PotionMixed = true
	if not has_logged_mix_finished:
		DebugManager.debug_log("Cauldron has finished mixing!")
		has_logged_mix_finished = true
