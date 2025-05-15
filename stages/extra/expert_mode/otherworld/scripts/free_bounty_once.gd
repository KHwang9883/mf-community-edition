extends Node

signal free_everything_no_candy

func _ready() -> void:
	if "special_otherworld_candy" in Data.technical_values && Data.technical_values.special_otherworld_candy:
		free_everything_no_candy.emit()

func activate() -> void:
	Data.technical_values.special_otherworld_candy = true
