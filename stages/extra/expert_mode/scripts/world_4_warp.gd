extends "res://stages/world_1/scripts/text_secret_passage.gd"

const expert_1_1 := &"res://stages/world_1/expert_level_1-1.tscn"

func activate() -> void:
	if ProfileManager.current_profile.has_completed(expert_1_1):
		ProfileManager.current_profile.data.completed_levels.erase(expert_1_1)
	if ProfileManager.current_profile.data.get("star_world") && "map_force_selected_marker" in Data.values:
		Data.values.map_force_selected_marker = ""
	super()
