extends Node

var wantedPotionType: String = "null"
var submittedPotionType: String = "null"

var customerSatisfaction = 0

var customer_effects: Array[String] = ["none", "none", "none", "none", "none", "none"]


func randomizeWantedType() -> void:
	var unlocked_ingredients: Array[String] = []
	if PotionJournal and PotionJournal.has_method("get_unlocked_ingredients"):
		unlocked_ingredients = PotionJournal.get_unlocked_ingredients()
	else:
		unlocked_ingredients = ["ElbowGrease", "OilOfVitriol", "Wormwood", "EyeOfNewt"]
	
	var valid_potions: Array[String] = []
	
	# Check each recipe in PotionDatabase against currently unlocked ingredients
	for recipe_ingredients in PotionDatabase.RECIPES.keys():
		var can_craft: bool = true
		for ing in recipe_ingredients:
			if not unlocked_ingredients.has(ing):
				can_craft = false
				break
		
		if can_craft:
			valid_potions.append(PotionDatabase.RECIPES[recipe_ingredients]["name"])

	if not valid_potions.is_empty():
		wantedPotionType = valid_potions.pick_random()
	else:
		wantedPotionType = "Potion of Curing"


func submitPotion(potion: String) -> void:
	submittedPotionType = potion
