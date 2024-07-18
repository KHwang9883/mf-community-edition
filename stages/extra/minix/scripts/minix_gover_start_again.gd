extends MenuSelection

@onready var starter: Node2D = $"../../../Node2D"
@onready var _is_simple_fade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)

func _handle_select() -> void:
	super()
	Data.reset_all_values()
	Data.values.minix_continue = starter.map_id
	Pause.get_child(0).open_blocked = false
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

