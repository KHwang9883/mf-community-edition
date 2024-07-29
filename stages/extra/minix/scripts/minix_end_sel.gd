extends MenuSelection

@onready var _is_simple_fade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)

func _handle_select() -> void:
	super()
	Pause.get_child(0).open_blocked = false
	Audio.stop_all_musics()
	Data.reset_all_values()
	if !_is_simple_fade:
		TransitionManager.transition_middle.connect(func():
			TransitionManager.current_transition.paused = true
			Scenes.goto_scene(ProjectSettings.get("application/thunder_settings/save_game_room_path"))
			Scenes.scene_ready.connect(func():
				TransitionManager.current_transition.paused = false
			, CONNECT_ONE_SHOT)
		, CONNECT_ONE_SHOT | CONNECT_DEFERRED)
	Audio.stop_music_channel(2, true)
	_start_transition()


func _start_transition() -> void:
	if !_is_simple_fade:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
				.instantiate()
				.with_speeds(0.02, -0.1)
		)
	else:
		Scenes.goto_scene(ProjectSettings.get("application/thunder_settings/save_game_room_path"))
		#TransitionManager.accept_transition(
		#	load("res://engine/components/transitions/crossfade_transition/crossfade_transition.tscn")
		#		.instantiate()
		#		.with_scene(ProjectSettings.get("application/thunder_settings/main_menu_path"))
		#)
