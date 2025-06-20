extends "res://engine/objects/players/deaths/player_death.gd"

func _start_transition() -> void:
	# Transition (tweaked, crossfade)
	if _is_simple_fade:
		#var _scene = Scenes.current_scene.scene_file_path if jump_to_scene.is_empty() else jump_to_scene
		Audio.stop_all_sounds()
		Scenes.current_scene.restart.call_deferred()
		#TransitionManager.accept_transition(
		#load("res://engine/components/transitions/crossfade_transition/crossfade_transition.tscn")
		#	.instantiate()
		#	.with_scene(_scene)
		#)
		return
	_transition_circle()
