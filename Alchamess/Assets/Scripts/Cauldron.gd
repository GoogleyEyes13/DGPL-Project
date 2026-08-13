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
	print("CURRENT CAULDRON INGREDIENTS: ", CauldronIngredients)
