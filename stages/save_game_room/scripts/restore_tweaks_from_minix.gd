extends Node

func _ready() -> void:
	SettingsManager.load_tweaks()
	CharacterManager.forced_character = ""
	ProjectSettings.set_setting(
		"application/thunder_settings/player/gameover_continues", -1
	)
	Data.technical_values.remaining_continues = -1
	Data.technical_values.erase("special_otherworld_toad")
	Data.technical_values.erase("special_otherworld_candy")
	Data.technical_values.erase("saved_lives")
	Data.technical_values.erase("otherworld_lvl_1")
	Data.technical_values.custom_saved_values = {}
	Scenes.custom_scenes.game_over.custom_resume_scene = ""
	
	if Data.technical_values.erase("lavarun_lives"):
		print("Granola bars")
	Data.technical_values.erase("lavarun_difficulty")
	
	if Scenes.previous_scene_path == "res://stages/extra/minix/minix.tscn":
		Data.values.erase("map_id")
		Data.values.erase("minix_continue")
	
	# Add achievements from old versions
	old_versions_achievements_patch()
	
func old_versions_achievements_patch() -> void:
	set_syzx_secret("syzx worlds completed",
		"syzxchulun world 9",
		"syzxchulun world 10"
	)
	set_syzx_secret("syzx worlds secret mode",
		"syzxchulun world 9 kevin mode",
		"syzxchulun world 10 kevin mode"
	)
	set_syzx_secret("syzx worlds completed softendo",
		"syzxchulun world 9 softendo",
		"syzxchulun world 10 advance"
	)
	set_syzx_secret("syzx worlds secret mode softendo",
		"syzxchulun world 9 softendo kevin mode",
		"syzxchulun world 10 advance kevin mode"
	)

func set_syzx_secret(secret_name: String, w9: String, w10: String) -> void:
	var arr_1 = SecretsManager.get_secret(secret_name)
	if arr_1 && arr_1 is Array:
		if "9" in arr_1 && !SecretsManager.has_secret(w9):
			SecretsManager.set_secret(w9, true, true, false)
		if "10" in arr_1 && !SecretsManager.has_secret(w10):
			SecretsManager.set_secret(w10, true, true, false)
	
