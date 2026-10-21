class_name CharacterData

const FOLDER_MAP: Dictionary = {
	"Queso": "Caseoh",
	"Caseoh": "Caseoh",
	"HerbBert": "Herb Bert",
	"Herb Bert": "Herb Bert",
	"MrMonicle": "Mr Monicle",
	"Mr Monicle": "Mr Monicle",
	"LadyP": "LadyP",
	"Lady P": "LadyP"
}

const PREFIX_MAP: Dictionary = {
	"Queso": "Caseoh",
	"Caseoh": "Caseoh",
	"HerbBert": "HerbBert",
	"Herb Bert": "HerbBert",
	"MrMonicle": "MrMonicle",
	"Mr Monicle": "MrMonicle",
	"LadyP": "LadyP",
	"Lady P": "LadyP"
}

static func get_folder(character_name: String) -> String:
	return FOLDER_MAP.get(character_name.strip_edges(), character_name.strip_edges())

static func get_prefix(character_name: String) -> String:
	var clean = character_name.strip_edges()
	return PREFIX_MAP.get(clean, clean.replace(" ", ""))

static func get_sprite_path(character_name: String, suffix: String = "Normal") -> String:
	var clean_name = character_name.strip_edges()
	if clean_name.is_empty():
		clean_name = "HerbBert"
		
	var folder = get_folder(clean_name)
	var prefix = get_prefix(clean_name)
	var base = "res://Assets/Sprites/%s/%s" % [folder, prefix]
	var full_path = "%s%s.png" % [base, suffix]
	
	if not ResourceLoader.exists(full_path) and suffix == "Normal":
		var alt = "%s.png" % base
		if ResourceLoader.exists(alt):
			return alt
			
	return full_path

static func get_dialogue_path(character_name: String, suffix: String = "") -> String:
	var path = "res://Dialogue/%s%s.dialogue" % [character_name.strip_edges(), suffix]
	if ResourceLoader.exists(path):
		return path
	return "res://Dialogue/HerbBert%s.dialogue" % suffix
