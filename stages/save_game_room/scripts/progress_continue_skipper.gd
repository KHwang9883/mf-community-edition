extends Node

func skip_continue_save():
	Data.values.skip_progress_continue = true
	if KevinGlobal.activated:
		ProfileManager.current_profile.data.kevin_mode_enabled = true
