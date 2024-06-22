extends Level

@onready var final_boss_cell = $FinalBossCell

func finish(walking: bool = false, walking_dir: int = 1) -> void:
	final_boss_cell.cutscene()

func throw_to_scene() -> void:
	await get_tree().create_timer(0.8, false, false).timeout
			
	if jump_to_scene:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
				.instantiate()
				.with_speeds(0.04, -0.1)
		)
		
		TransitionManager.transition_middle.connect(func():
			TransitionManager.current_transition.paused = true
			Scenes.goto_scene(jump_to_scene)
			Scenes.scene_changed.connect(func(_current_scene):
				TransitionManager.current_transition.paused = false
			, CONNECT_ONE_SHOT)
		, CONNECT_ONE_SHOT)
	else:
		printerr("[Level] Jump to scene is not defined in the level.")
