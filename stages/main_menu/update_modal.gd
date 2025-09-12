extends "res://engine/scenes/main_menu/scripts/restart_popup.gd"

@export var delay_controls: bool = false

func toggle(no_resume: bool = false, no_sound_effect: bool = false) -> void:
	#if !v_box_container.focused && opened: return

	if open_blocked: return

	opened = !opened
	if opened:
		popped.emit()
	else:
		closed.emit()

	$'..'.offset = Vector2.ZERO

	if opened:
		v_box_container.move_selector(0, true)
		animation_player.play("fade")
		SettingsManager.show_mouse()
		Console.hide()
		get_tree().paused = true
		if delay_controls:
			v_box_container.modulate.v = 0.3
			if Scenes.current_scene is Stage2D:
				Scenes.current_scene.disable_pause_menu = true
		
	else:
		animation_player.play_backwards("fade")

	for i in 2:
		await get_tree().physics_frame
	
	if delay_controls && opened:
		v_box_container.modulate.v = 0.3
		await get_tree().create_timer(1.2, true, false, true).timeout
		v_box_container.focused = true
		var tw = create_tween()
		tw.tween_property(v_box_container, "modulate:v", 1.0, 0.5)
	else:
		v_box_container.focused = opened
	if !opened:
		get_tree().paused = false
		if delay_controls:
			if Scenes.current_scene is Stage2D:
				Scenes.current_scene.disable_pause_menu = false
	#options.focused = false
	#controls_options.focused = false
