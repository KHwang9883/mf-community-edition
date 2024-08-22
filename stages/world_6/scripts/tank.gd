extends Node2D

@export var limit: float

func _physics_process(delta: float) -> void:
	if global_position.x > limit:
		global_position.x -= delta * 28
	elif global_position.x < limit:
		global_position.x = limit

func _asfhpsofu() -> void:
	var profile = ProfileManager.current_profile
	var path = scene_file_path
	if !profile.has_completed(path):
		profile.complete_level(path)
		ProfileManager.save_current_profile()
