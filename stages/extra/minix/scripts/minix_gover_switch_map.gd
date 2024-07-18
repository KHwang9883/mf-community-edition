extends MenuSelection

@onready var _is_simple_fade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)

func _handle_select() -> void:
	super()
	get_tree().paused = false
	Pause.get_child(0).open_blocked = false
	Audio.stop_all_musics()
	_start_transition()


func _start_transition() -> void:
	if !_is_simple_fade:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
				.instantiate()
				.with_speeds(0.02, -0.1)
		)
	else:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/crossfade_transition/crossfade_transition.tscn")
				.instantiate()
				.with_scene("res://stages/extra/minix/minix.tscn")
		)

