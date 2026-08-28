extends CharacterBody2D

# A dictionary to store all the recieved ingredients
var CauldronIngredients: Dictionary = {}

# A dictionary to store all potion combinations
var PotionRecipes: Dictionary = {
	["ElbowGrease", "OilOfVitriol", "PhoenixFeather"]: "Potion of Mogging",
	["OilOfVitriol", "PhoenixFeather", "Wormwood"]: "Potion of Beutification",
	["ElbowGrease", "OilOfVitriol", "Stardust"]: "Potion of Rapid Shaking",
	["ElbowGrease", "EyeOfNewt", "PhoenixFeather"]: "Potion of Eye Colour Swap",
	["ElbowGrease", "EyeOfNewt", "Wormwood"]: "Potion of Permanent Smile",
	["EyeOfNewt", "PhoenixFeather", "Wormwood"]: "Potion of Green Skin",
	["ElbowGrease", "PhoenixFeather", "Wormwood"]: "Potion of Curing",
	["EyeOfNewt", "OilOfVitriol", "Wormwood"]: "Potion Of Baldness",
	["ElbowGrease", "OilOfVitriol", "Wormwood"]: "Potion of Head Size Increase",
	["ElbowGrease", "EyeOfNewt", "OilOfVitriol"]: "Potion of Head Size Decrease",
	["EyeOfNewt", "PhoenixFeather", "Stardust"]: "Potion of Creature Feature",
	["ElbowGrease", "Wormwood", "Stardust"]: "Potion of Rabies",
	["PhoenixFeather", "Stardust", "Wormwood"]: "Potion of Change Language",
	["EyeOfNewt", "Stardust", "Wormwood"]: "Potion of Change Art Styles",
	["ElbowGrease", "PhoenixFeather", "Stardust"]: "Potion of Body Swap",
	["ElbowGrease", "EyeOfNewt", "Stardust"]: "Potion of Love",
	["OilOfVitriol", "PhoenixFeather", "Stardust"]: "Potion of Explode",
	["EyeOfNewt", "OilOfVitriol", "PhoenixFeather"]: "Potion of Skeleton/Ghost",
	["OilOfVitriol", "Stardust", "Wormwood"]: "Potion of Enlarge Person",
	["EyeOfNewt", "OilOfVitriol", "Stardust"]: "Potion of Shrink Person"
}

# Potion bottles
@onready var Potion = $"../CraftedPotion"

# A signal to send to the customer when a potion is made
signal potion_created

func _ready():
	# Connecting ingredient added signal for each ingredient
	$"../EyeOfNewt".ingredient_added.connect(_add_ingredient_to_cauldron)
	$"../Wormwood".ingredient_added.connect(_add_ingredient_to_cauldron)
	$"../ElbowGrease".ingredient_added.connect(_add_ingredient_to_cauldron)
	$"../PhoenixFeather".ingredient_added.connect(_add_ingredient_to_cauldron)
	$"../OilOfVitriol".ingredient_added.connect(_add_ingredient_to_cauldron)
	$"../Stardust".ingredient_added.connect(_add_ingredient_to_cauldron)


func _add_ingredient_to_cauldron(name):
	if CauldronIngredients.size() > 3:
		# If cauldron already has 3 ingredients, don't add another
		print("Cauldron full")
		
		return
	
	if CauldronIngredients.has(name):
		# If ingredient is already in the pot, don't add another
		print(name, " is already in the pot")
		return
	
	# Add ingredient to the pot
	CauldronIngredients[name] = 1
	print(name, " has been placed in the pot")
	
	if CauldronIngredients.size() == 3:
		# Create the potion based on ingredient combination
		create_potion()
		
		# Spawning potion sprite, resetting ingredients
		Potion.visible = true
		CauldronIngredients = {}
		
		# Short timeout to prevent instant ingredient add
		get_tree().create_timer(1.0).timeout
	
	print("CURRENT CAULDRON INGREDIENTS: ", CauldronIngredients)
	
	
func create_potion():
		# Getting the current cauldron ingredients and sorting them
		var Ingredients = CauldronIngredients.keys()
		
		# Converting the node StringNames to Strings
		for i in range(Ingredients.size()):
			Ingredients[i] = str(Ingredients[i])
		
		# Sorting them alphabetically
		Ingredients.sort()
		
		if PotionRecipes.has(Ingredients):
			var Potion = PotionRecipes[Ingredients]
			print("Created: ", Potion)
			potion_created.emit(Potion)
		else:
			print(Ingredients)
			print("Invalid combination")
