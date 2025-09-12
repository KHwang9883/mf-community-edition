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
		
	else:
		animation_player.play_backwards("fade")

	for i in 2:
		await get_tree().physics_frame
	
	if delay_controls && opened:
		v_box_container.modulate.v = 0.4
		await get_tree().create_timer(2.0, true, false, true).timeout
		v_box_container.focused = true
		var tw = create_tween()
		tw.tween_property(v_box_container, "modulate:v", 1.0, 0.5)
	else:
		v_box_container.focused = opened
	if !opened: get_tree().paused = false
	#options.focused = false
	#controls_options.focused = false
