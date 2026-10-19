extends Node

var wantedPotionType: String = "null"
var submittedPotionType: String = "null"

var customer_effects: Array[String] = ["none", "none", "none", "none", "none", "none"]


func randomizeWantedType() -> void:
	var all_potions: Array[String] = PotionDatabase.get_all_potion_types()
	if not all_potions.is_empty():
		wantedPotionType = all_potions.pick_random()
	else:
		wantedPotionType = "Potion of Curing"


func submitPotion(potion: String) -> void:
	submittedPotionType = potion
