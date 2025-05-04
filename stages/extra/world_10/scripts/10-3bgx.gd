extends AnimationPlayer


func _ready() -> void:
	Thunder._current_player.died.connect(pause)
	animation_finished.connect(func(anim: StringName) -> void:
		play(anim)
		seek(1.04, true, false)
	)
	
	(Scenes.current_scene as Level).level_completed.connect(pause, CONNECT_ONE_SHOT)
