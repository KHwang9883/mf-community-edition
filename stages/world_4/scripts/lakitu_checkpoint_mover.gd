extends Node

@export var cp_x_pos: Dictionary[int, float]

func _ready() -> void:
	if Data.values.checkpoint != -1:
		if Data.values.checkpoint in cp_x_pos:
			$"..".position.x = cp_x_pos[Data.values.checkpoint]
