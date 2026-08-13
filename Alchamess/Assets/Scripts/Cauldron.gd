extends CharacterBody2D

# A dictionary to store all the recieved ingredients
var CauldronIngredients: Dictionary = {}

func _ready():
	# Connecting ingredient added signal for each ingredient
	$"../EyeOfNewt".ingredient_added.connect(_add_ingredient_to_cauldron)
	$"../Wormwood".ingredient_added.connect(_add_ingredient_to_cauldron)
	$"../MagicPebble".ingredient_added.connect(_add_ingredient_to_cauldron)
	$"../PhoenixFeather".ingredient_added.connect(_add_ingredient_to_cauldron)
	$"../OilOfVitriol".ingredient_added.connect(_add_ingredient_to_cauldron)
	$"../Stardust".ingredient_added.connect(_add_ingredient_to_cauldron)

func _add_ingredient_to_cauldron(name):
	# Adding ingredient to the dictionary
	if CauldronIngredients.has(name):
		CauldronIngredients[name] += 1
	else:
		CauldronIngredients[name] = 1
	
	print("CURRENT CAULDRON INGREDIENTS: ", CauldronIngredients)
