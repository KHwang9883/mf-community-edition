extends Node

func _ready() -> void:
	await get_tree().physics_frame
	if SecretsManager.is_console_enabled():
		ProfileManager.current_profile.data.executed = true

func skip_continue_save():
	Data.values.skip_progress_continue = true
	if KevinGlobal.activated:
		ProfileManager.current_profile.data.kevin_mode_enabled = true


func set_advanced_edition() -> void:
	ProfileManager.current_profile.data.advanced_edition = true
	skip_continue_save()


func set_regular_edition() -> void:
	ProfileManager.current_profile.data.advanced_edition = false
	skip_continue_save()


func mario_forever_advance() -> void:
	ProfileManager.current_profile.data.mario_forever_advance = true
	SettingsManager.set_tweak("life_every_2_mil_score", false)
	SettingsManager.set_tweak("stomping_combo", false)
	SettingsManager.set_tweak("harder_level_design", true)
	SettingsManager.set_tweak("minigames_in_main_worlds", true)
	#SettingsManager.set_tweak("bowser_stomping", true)
	#SettingsManager.set_tweak("better_springboards", false)
