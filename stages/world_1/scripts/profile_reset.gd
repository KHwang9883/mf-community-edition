extends Node

func profile_reset() -> void:
	Data.values.goto_human_lab = "true"
	var profile = ProfileManager.current_profile
	var path = Scenes.current_scene.scene_file_path
	if !profile.has_completed(path):
		profile.complete_level(path)
		ProfileManager.save_current_profile()
	
	#ProfileManager.create_new_profile(&"debug")
