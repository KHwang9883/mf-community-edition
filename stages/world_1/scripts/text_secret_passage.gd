extends CanvasItem

@export var tween_to := 240
@export var speed_sec := 0.8
@export_group("Actions")
@export var action_after_sec := 0.0
@export var fade_on_end := false
@export_file("*.tscn", "*.scn") var change_scene: String

func activate() -> void:
	var tw = create_tween()
	tw.tween_property(self, "position:y", tween_to, speed_sec).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	if !action_after_sec: return
	
	if fade_on_end:
		tw.tween_interval(action_after_sec)
		tw.tween_property(self, "modulate:a", 0.0, 2.0)
	if change_scene:
		#ProfileManager.set_current_profile("debug")
		await get_tree().create_timer(action_after_sec, false).timeout
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
				.instantiate()
				.with_speeds(0.04, -0.1)
		)
		
		TransitionManager.transition_middle.connect(func():
			TransitionManager.current_transition.paused = true
			Scenes.goto_scene(change_scene)
			Scenes.scene_changed.connect(func(_current_scene):
				TransitionManager.current_transition.paused = false
			, CONNECT_ONE_SHOT)
		, CONNECT_ONE_SHOT)
