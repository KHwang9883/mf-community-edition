extends Node

func check_secret() -> void:
	if floor(Data.values.time) >= 70_000:
		get_parent().unlock_secret()
