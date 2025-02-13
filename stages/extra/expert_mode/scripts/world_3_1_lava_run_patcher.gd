extends Node

@export var climbing_set_difficulty: int
@export var climbing_after_scene: String

func hello() -> void:
	Data.values.onetime_blocks = true
	if !KevinGlobal.activated:
		Data.technical_values['lavarun_lives'] = Data.values.lives if Data.values.lives > 4 else 4
		if Data.values.lives > 4:
			Data.values.lives = 4
	Data.values['lavarun_difficulty'] = climbing_set_difficulty
	Data.values['lavarun_after'] = climbing_after_scene
