extends Control

@onready var disclaimer: TextureRect = $CenterContainer/TextureRect

func _ready() -> void:
	var tw = disclaimer.create_tween()
	tw.tween_property(disclaimer, "modulate:a", 1.0, 0.8)
	tw.tween_interval(2.2)
	tw.tween_property(disclaimer, "modulate:a", 0.0, 0.8)
	tw.tween_callback(transition)


func transition() -> void:
	var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)
	var mainmenu = ProjectSettings.get_setting("application/thunder_settings/main_menu_path")
	if !_crossfade:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
				.instantiate()
				.with_speeds(0.04, -0.1)
				.with_pause()
		)

		await TransitionManager.transition_middle
		Scenes.goto_scene(mainmenu)
	else:
		Scenes.goto_scene(mainmenu)
