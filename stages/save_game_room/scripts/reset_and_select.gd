extends "res://engine/scenes/save_game_room/scripts/reset.gd"

func _physics_process(delta: float) -> void:
	if !is_inside: return
	super(delta)
	if Input.is_action_just_pressed("a_tab"):
		Audio.play_1d_sound(preload("res://engine/components/hud/sounds/scoring.wav"))
