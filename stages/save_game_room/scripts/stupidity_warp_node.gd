extends Node

func trigger() -> void:
	Data.values.lives = 20
	Scenes.custom_scenes.game_over.skip_to_save = true
