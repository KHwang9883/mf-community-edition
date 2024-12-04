extends MenuSelection

@onready var starter: Node2D = $"../../../Node2D"
@onready var _is_simple_fade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)

func _handle_select(mouse_input: bool = false) -> void:
	Audio.stop_all_sounds()
	super(mouse_input)
	TransitionManager.transition_middle.connect(func():
		TransitionManager.current_transition.paused = true
		Scenes.goto_scene("res://stages/extra/minix/minix.tscn")
		Scenes.scene_ready.connect(func():
			TransitionManager.current_transition.on(Thunder._current_player)
			if !Thunder._current_player:
				TransitionManager.current_transition.paused = false
		, CONNECT_ONE_SHOT)
		get_tree().set_deferred("paused", false)
	, CONNECT_ONE_SHOT | CONNECT_DEFERRED)
	Data.reset_all_values()
	Data.values.minix_continue = starter.map_id
	Data.values.map_id = starter.map_id
	Pause.get_child(0).open_blocked = false
	SettingsManager.hide_mouse()
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
