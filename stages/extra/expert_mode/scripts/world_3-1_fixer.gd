extends Node

@export var path: String = "res://stages/world_3/expert_level_3-1.tscn"

func _ready() -> void:
	if !ProfileManager.current_profile.has_completed(path):
		ProfileManager.current_profile.complete_level(path)
		ProfileManager.save_current_profile()
