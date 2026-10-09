extends Node

var wantedPotionType = "null"
var submittedPotionType = "null"
var customer1Effect = "none"
var customer2Effect = "none"
var customer3Effect = "none"
var customer4Effect = "none"
var customer5Effect = "none"
var customer6Effect = "none"

#func randomizeWantedType():
#	wantedPotionType = ["MogFace", "Beautification", "ShakeRapidly", "EyeColourSwap", "PermanentSmile", "GreenSkin", "Cure", "Bald", "HeadSizeIncrease", "HeadSizeDecrease", "CreatureFeature", "Rabies", "ChangeLanguage", "ChangeArtStyle", "SwapBodies", "Love", "Explode", "Skeleton", "EnlargePerson", "ShrinkPerson"].pick_random()
# this function is outdated because i found the potion strings work differently than how ive been writing them. keeping this in for archival purposes

func randomizeWantedType():
	match randi_range(1,20):
		1:
			wantedPotionType = "Potion of Rabies"
		2:
			wantedPotionType = "Potion of Curing"
		3:
			wantedPotionType = "Potion of Rapid Shaking"
		4:
			wantedPotionType = "Potion of Permanent Smile"
		5:
			wantedPotionType = "Potion of Explode"
		6:
			wantedPotionType = "Potion of Change Language"
		7:
			wantedPotionType = "Potion of Mogging"
		8:
			wantedPotionType = "Potion of Body Swap"
		9:
			wantedPotionType = "Potion of Love"
		10:
			wantedPotionType = "Potion of Enlarge Person"
		11:
			wantedPotionType = "Potion of Shrink Person"
		12:
			wantedPotionType = "Potion Of Baldness"
		13:
			wantedPotionType = "Potion of Head Size Increase"
		14:
			wantedPotionType = "Potion of Head Size Decrease"
		15:
			wantedPotionType = "Potion of Green Skin"
		16:
			wantedPotionType = "Potion of Eye Colour Swap"
		17:
			wantedPotionType = "Potion of Skeleton"
		18:
			wantedPotionType = "Potion of Change Art Styles"
		19:
			wantedPotionType = "Potion of Creature Feature"
		20:
			wantedPotionType = "Potion of Beautification"

func submitPotion(potion : String):
	submittedPotionType = potion
