@tool
extends Level

func finish(walking: bool = false, walking_dir: int = 1) -> void:
	if !Thunder._current_player: return
	if _level_has_completed:
		return
	level_completed.emit()
	if (
		Thunder.autosplitter.can_split_on("level_end_always")
	):
		Thunder.autosplitter.split("Level Ended")
	Thunder.autosplitter.update_il_counter()
	_level_has_completed = true
	print("[Game] Level complete.")

	Thunder._current_hud.timer.paused = true
	Thunder._current_player.completed = true
	Audio.stop_all_musics()

	Data.values.onetime_blocks = true
	Thunder._current_player.left_right = 0

	await get_tree().physics_frame
	
	# Do not switch scenes if game over screen is opened, might be rare but just in case
	if Scenes.custom_scenes.get("game_over"):
		if Scenes.custom_scenes.game_over.get("opened"):
			return
	var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)
	Data.values.checkpoint = -1
	Data.values.checked_cps = []

	if jump_to_scene:
		if !_crossfade:
			TransitionManager.accept_transition(
				load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
					.instantiate()
					.with_speeds(0.04, -0.1)
					.with_pause()
					.on_player_after_middle(completion_center_on_player_after_transition)
			)

			await TransitionManager.transition_middle
			Scenes.goto_scene(jump_to_scene)
		else:
			TransitionManager.accept_transition(
				load("res://engine/components/transitions/crossfade_transition/crossfade_transition.tscn")
					.instantiate()
					.with_scene(jump_to_scene)
			)
	
	if completion_write_save:
		ProfileManager.current_profile.data.star_world = true
		ProfileManager.save_current_profile()
	if !(SecretsManager.is_console_enabled() && !Console.cv.can_save_suspended_with_console):
		if (
			ProfileManager.profiles.has("suspended") &&
			ProfileManager.profiles.suspended.data.saved_profile == ProfileManager.current_profile.name
		):
			ProfileManager.delete_profile(&"suspended")
