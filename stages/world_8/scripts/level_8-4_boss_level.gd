extends Level

@onready var final_boss_cell = $FinalBossCell
@onready var music_loader: Node = $MusicLoader

func finish(walking: bool = false, walking_dir: int = 1) -> void:
	if !Thunder._current_player: return
	if (
		Thunder.autosplitter.can_split_on("level_end_always") ||
		(Thunder.autosplitter.can_split_on("level_end_no_boss") && !has_meta(&"boss_got_defeated"))
	):
		Thunder.autosplitter.split("Level Ended")
	level_completed.emit()
	final_boss_cell.cutscene()
	music_loader.play_buffered()

func throw_to_scene() -> void:
	if Thunder.autosplitter.can_split_on("achievement_classic") && !SecretsManager.has_secret("story mode completed"):
		Thunder.autosplitter.split("Classic Achievement")
	SecretsManager.set_secret("story mode completed", true)
	ProfileManager.current_profile.data.star_world = true
	ProfileManager.save_current_profile()
	if !(SecretsManager.is_console_enabled() && !Console.cv.can_save_suspended_with_console):
		if (
			ProfileManager.profiles.has("suspended") &&
			ProfileManager.profiles.suspended.data.saved_profile == ProfileManager.current_profile.name
		):
			ProfileManager.delete_profile(&"suspended")
	await get_tree().create_timer(0.8, false, false).timeout
	var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)

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
	else:
		printerr("[Level] Jump to scene is not defined in the level.")
