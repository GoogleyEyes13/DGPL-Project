extends Sprite2D

var has_logged_mix_finished: bool = false
var CauldronIngredients: Dictionary = {}

var ingredient_usage_counts: Dictionary = {
	"ElbowGrease": 0,
	"EyeOfNewt": 0,
	"OilOfVitriol": 0,
	"PhoenixFeather": 0,
	"Stardust": 0,
	"Wormwood": 0
}

# Cauldron ingredient spawn points
var Ingredient1 = Vector2(-406, 370)
var Ingredient2 = Vector2(7, 370)
var Ingredient3 = Vector2(410, 370)

# Pot ingredient sprites
@onready var IngredientsInCauldron = $WitchCauldronInside
@onready var MixingStick = $"../MixingStick"
@onready var in_pot_sfx: AudioStreamPlayer = $InPotSFX
@onready var area_2d: Area2D = $Area2D

var CauldronFull: bool = false
var LastPotionCreated: String = "None"
var PotionMixed: bool = false

signal ingredients_updated(ingredients: Array, last_potion: String)
signal potion_bottle_filled(bottle_type: String, potion_name: String)
signal ingredient_counts_updated(counts: Dictionary)

var in_pot_sounds: Dictionary = {
	"ElbowGrease": preload("res://Assets/Audio/SFX/Ingredients in Pot/elbow grease.wav"),
	"EyeOfNewt": preload("res://Assets/Audio/SFX/Ingredients in Pot/eye of newt.wav"),
	"OilOfVitriol": preload("res://Assets/Audio/SFX/Ingredients in Pot/oil of vitriol.wav"),
	"PhoenixFeather": preload("res://Assets/Audio/SFX/Ingredients in Pot/phoenix feather.wav"),
	"Stardust": preload("res://Assets/Audio/SFX/Ingredients in Pot/stardust.wav"),
	"Wormwood": preload("res://Assets/Audio/SFX/Ingredients in Pot/wormwood.wav"),
}


func _ready() -> void:
	DebugManager.register_cauldron(self)
	if MixingStick:
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

	_show_ingredient_in_pot(ingredient_name)
	
	if in_pot_sounds.has(ingredient_name):
		in_pot_sfx.stream = in_pot_sounds[ingredient_name]
		in_pot_sfx.play()
	
	ingredients_updated.emit(CauldronIngredients.keys(), LastPotionCreated)
	
	if CauldronIngredients.size() == 3:
		CauldronFull = true

		var ingredients_list: Array = CauldronIngredients.keys()
		var potion_data: Dictionary = PotionDatabase.get_potion_data(ingredients_list)
		
		if not potion_data.is_empty():
			LastPotionCreated = potion_data["name"]
			DebugManager.debug_log("Potion identified: " + LastPotionCreated)
		else:
			LastPotionCreated = "Unknown Potion"
			DebugManager.debug_log("No potion recipe found!")
		
		ingredients_updated.emit(CauldronIngredients.keys(), LastPotionCreated)
		if MixingStick:
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
			if LastPotionCreated != "Unknown Potion" and LastPotionCreated != "None":
				var ingredients_list: Array = CauldronIngredients.keys()
				
				for ingredient in ingredients_list:
					if ingredient_usage_counts.has(ingredient):
						ingredient_usage_counts[ingredient] += 1
				
				ingredient_counts_updated.emit(ingredient_usage_counts)
				
				if target_node.has_method("fill_bottle"):
					target_node.fill_bottle(LastPotionCreated)
				
				potion_bottle_filled.emit(target_node.potionName, LastPotionCreated)
				
				# Reset state
				if MixingStick:
					MixingStick.reset_liquid_colour()
				PotionMixed = false
				CauldronFull = false
				CauldronIngredients = {}
				has_logged_mix_finished = false
				
				for child in IngredientsInCauldron.get_children():
					child.visible = false
				
				ingredients_updated.emit(CauldronIngredients.keys(), LastPotionCreated)
				PotionJournal.register_potion(LastPotionCreated, ingredients_list)


func _on_potion_mixed() -> void:
	PotionMixed = true
	if not has_logged_mix_finished:
		DebugManager.debug_log("Cauldron has finished mixing!")
		has_logged_mix_finished = true


func _show_ingredient_in_pot(ingredient_name: String) -> void:
	var ingredient_sprite = IngredientsInCauldron.get_node_or_null(ingredient_name)
	if ingredient_sprite == null:
		DebugManager.debug_log("Ingredient sprite not found: " + ingredient_name)
		return

	var spawn_points: Array[Vector2] = [Ingredient1, Ingredient2, Ingredient3]
	var occupied_positions: Array[Vector2] = []

	for child in IngredientsInCauldron.get_children():
		if child.visible:
			occupied_positions.append(child.position)

	for spawn_point in spawn_points:
		if not occupied_positions.has(spawn_point):
			ingredient_sprite.position = spawn_point
			ingredient_sprite.visible = true
			return
