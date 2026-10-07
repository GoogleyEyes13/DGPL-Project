extends Control

@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var count_label: Label = $Label

@export var max_count: int = 10
@export var value: int = 0

func _ready() -> void:
	update_count(value)

func update_count(count: int) -> void:
	value = count
	
	if progress_bar:
		progress_bar.max_value = max_count
		progress_bar.value = count
		
	if count_label:
		count_label.text = str(count)
