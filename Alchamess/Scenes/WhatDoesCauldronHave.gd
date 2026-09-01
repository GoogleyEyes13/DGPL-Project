extends Label

func _ready() -> void:
	$"../WitchCauldron".ingredients_updated.connect(_on_ingredients_updated)
	text = ""

func _on_ingredients_updated(ingredients: Array, last_potion: String) -> void:
	var ingredients_text: String = "Cauldron: empty" if ingredients.is_empty() else "Cauldron: " + ", ".join(ingredients)
	text = ingredients_text + "\nLast potion: " + last_potion
