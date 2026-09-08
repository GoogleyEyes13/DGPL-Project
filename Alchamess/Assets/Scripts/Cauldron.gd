extends CharacterBody2D

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
@onready var CauldronFull = false

# A signal to send to the customer when a potion is made
signal ingredients_updated(ingredients: Array, last_potion: String)
signal potion_bottle_filled

var LastPotionCreated: String = "None"

func _ready():
	pass

func _add_ingredient_to_cauldron(ingredient_ingredient_name):
	if CauldronIngredients.size() >= 3:
		# If cauldron already has 3 ingredients, don't add another
		print("Cauldron full")
		
		return 
	
	if CauldronIngredients.has(ingredient_ingredient_name):
		# If ingredient is already in the pot, don't add another
		print(ingredient_ingredient_name, " is already in the pot")
		return
	
	# Add ingredient to the pot
	CauldronIngredients[ingredient_ingredient_name] = 1
	print(ingredient_ingredient_name, " has been placed in the pot")
	ingredients_updated.emit(CauldronIngredients.keys(), LastPotionCreated)
	
	if CauldronIngredients.size() == 3:		
		# Setting CauldronFull to true
		CauldronFull = true
		ingredients_updated.emit(CauldronIngredients.keys(), LastPotionCreated)
	
	print("CURRENT CAULDRON INGREDIENTS: ", CauldronIngredients)


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
		print("Potion bottle detected")
		# Check if the cauldron is full, if so, then fill the potion bottle
		if CauldronFull == true:
			var potion_name = PotionRecipes[Ingredients]
			LastPotionCreated = potion_name
			potion_bottle_filled.emit(body.potionName, LastPotionCreated)
			CauldronFull = false
			CauldronIngredients = {}
			# Updating label
			ingredients_updated.emit(CauldronIngredients.keys(), LastPotionCreated)
			# Updating journal
			PotionJournal.register_potion(potion_name, Ingredients) 
		return
