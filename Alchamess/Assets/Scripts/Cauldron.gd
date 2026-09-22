extends CharacterBody2D

var has_logged_mix_finished: bool = false

# A dictionary to store all the recieved ingredients
var CauldronIngredients: Dictionary = {}

# A dictionary to store all potion combinations
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


@onready var Potion = $"../CraftedPotion"
@onready var MixingStick = $"../MixingStick"
@onready var CauldronFull = false

# A signal to send to the customer when a potion is complete
signal ingredients_updated(ingredients: Array, last_potion: String)
signal potion_bottle_filled

var LastPotionCreated: String = "None"

# Potion mixed state
var PotionMixed = false

# Ingredient/potion sounds
var in_pot_sounds: Dictionary = {
	"ElbowGrease": preload("res://Assets/Audio/SFX/Ingredients in Pot/elbow grease.wav"),
	"EyeOfNewt": preload("res://Assets/Audio/SFX/Ingredients in Pot/eye of newt.wav"),
	"OilOfVitriol": preload("res://Assets/Audio/SFX/Ingredients in Pot/oil of vitriol.wav"),
	"PhoenixFeather": preload("res://Assets/Audio/SFX/Ingredients in Pot/phoenix feather.wav"),
	"Stardust": preload("res://Assets/Audio/SFX/Ingredients in Pot/stardust.wav"),
	"Wormwood": preload("res://Assets/Audio/SFX/Ingredients in Pot/wormwood.wav"),
}
@onready var in_pot_sfx: AudioStreamPlayer = $InPotSFX

func _ready():
	$"../MixingStick".potion_mixed.connect(_on_potion_mixed)

func _add_ingredient_to_cauldron(ingredient_ingredient_name):
	if CauldronIngredients.size() >= 3:
		# If cauldron already has 3 ingredients, don't add another
		DebugManager.debug_log("Cauldron full")
		
		return 
	
	if CauldronIngredients.has(ingredient_ingredient_name):
		# If ingredient is already in the pot, don't add another
		DebugManager.debug_log(ingredient_ingredient_name + " is already in the pot")
		return
	
	# Add ingredient to the pot
	CauldronIngredients[ingredient_ingredient_name] = 1
	DebugManager.debug_log(ingredient_ingredient_name + " has been placed in the pot")
	
	if in_pot_sounds.has(ingredient_ingredient_name):
		in_pot_sfx.stream = in_pot_sounds[ingredient_ingredient_name]
		in_pot_sfx.play()
	
	ingredients_updated.emit(CauldronIngredients.keys(), LastPotionCreated)
	
	if CauldronIngredients.size() == 3:		
		# Setting CauldronFull to true
		CauldronFull = true
		ingredients_updated.emit(CauldronIngredients.keys(), LastPotionCreated)
		
		# Allow mixing stick to mix
		MixingStick.start_mixing()


# Function for detecting ingredients touching the cauldron
func _on_area_2d_body_entered(body: Node2D) -> void:
	# Getting the current cauldron ingredients and sorting them
	var Ingredients = CauldronIngredients.keys()
		
	# Converting the node Stringingredient_names to Strings
	for i in range(Ingredients.size()):
		Ingredients[i] = str(Ingredients[i])
		
	# Sorting them alphabetically
	Ingredients.sort()	

	if body is CharacterBody2D:
		# Check if object is an ingredient
		if body.has_method("return_ingredient_to_start"):
			_add_ingredient_to_cauldron(body.ingredientType)
			body.is_grabbed = false
			body.get_node("Sprite2D").visible = false
			body.return_ingredient_to_start()
			return
			
		# Otherwise, it's a potion bottle
		DebugManager.debug_log("Potion bottle detected")
		# Check if the cauldron is full, if so, then fill the potion bottle
		if CauldronFull == true and PotionMixed == true:
			var potion_name = PotionRecipes[Ingredients]
			LastPotionCreated = potion_name
			potion_bottle_filled.emit(body.potionName, LastPotionCreated)
			
			# Resetting potion mixing and cauldron
			MixingStick.reset_liquid_colour()
			PotionMixed = false
			CauldronFull = false
			CauldronIngredients = {}
			
			# Updating label and journal
			ingredients_updated.emit(CauldronIngredients.keys(), LastPotionCreated)
			PotionJournal.register_potion(potion_name, Ingredients) 
		return

func _on_potion_mixed() -> void:
	PotionMixed = true
	if not has_logged_mix_finished:
		DebugManager.debug_log("Cauldron has finished mixing!")
		has_logged_mix_finished = true
