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
@onready var SmokeTransition = $"../Smoke"

# A signal to send to the customer when a potion is made
signal potion_created
signal ingredients_updated(ingredients: Array, last_potion: String)

var LastPotionCreated: String = "None"

func _ready():
	pass


func _add_ingredient_to_cauldron(name):
	if CauldronIngredients.size() >= 3:
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
	ingredients_updated.emit(CauldronIngredients.keys(), LastPotionCreated)
	
	if CauldronIngredients.size() == 3:
		# Create the potion based on ingredient combination
		create_potion()
		
		# Spawning potion sprite, resetting ingredients
		Potion.visible = true
		CauldronIngredients = {}
		ingredients_updated.emit(CauldronIngredients.keys(), LastPotionCreated)
		
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
			LastPotionCreated = Potion
			PotionJournal.register_potion(Potion, Ingredients) 
			print("Created: ", Potion)
			SmokeTransition.visible = true
			SmokeTransition.play()
			await get_tree().create_timer(0.3).timeout
			potion_created.emit(Potion)
		else:
			print(Ingredients)
			print("Invalid combination")


# Function for detecting ingredients touching the cauldron
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_add_ingredient_to_cauldron(body.ingredientType)
		body.is_grabbed = false
		body.get_node("Sprite2D").visible = false
		body.return_ingredient_to_start()
		

# Making the smoke animation invisible after its played once
func _on_smoke_animation_finished() -> void:
	SmokeTransition.visible = false
