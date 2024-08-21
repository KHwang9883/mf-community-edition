extends Node

func profile_reset() -> void:
	ProfileManager.create_new_profile(&"debug")
