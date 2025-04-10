extends Node

func _ready() -> void:
	SettingsManager.load_tweaks()
	CharacterManager.forced_character = ""
	ProjectSettings.set_setting(
		"application/thunder_settings/player/gameover_continues", -1
	)
	Data.technical_values.remaining_continues = -1
	Scenes.custom_scenes.game_over.custom_resume_scene = ""
	
	SettingsManager.set_tweak("life_every_2_mil_score", false)
	if Data.technical_values.erase("lavarun_lives"):
		print("Granola bars")
	Data.technical_values.erase("lavarun_difficulty")
	
	if Scenes.previous_scene_path == "res://stages/extra/minix/minix.tscn":
		Data.values.erase("map_id")
		Data.values.erase("minix_continue")
