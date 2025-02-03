extends Node

@export var climbing_set_difficulty: int
@export var climbing_after_scene: String

func hello() -> void:
	Data.values['lavarun_difficulty'] = climbing_set_difficulty
	Data.values['lavarun_after'] = climbing_after_scene
