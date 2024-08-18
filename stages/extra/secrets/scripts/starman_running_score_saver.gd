extends Node

func save_score() -> void:
	SecretsManager.set_secret("starman_score", Data.values.time, true, false)
