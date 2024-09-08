extends Node

func save_score() -> void:
	var last_score = SecretsManager.get_secret("starman_score")
	if !last_score || floor(Data.values.time) > last_score:
		SecretsManager.set_secret("starman_score", floor(Data.values.time), true, false)
