extends "res://stages/world_8/scripts/level_8-4_boss_level.gd"

func throw_to_scene() -> void:
	await get_tree().create_timer(0.3, false, false).timeout
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
