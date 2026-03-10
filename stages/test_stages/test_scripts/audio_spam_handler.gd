extends Node

var brick_spam_enabled := false

func on_toggle_brick() -> void:
	brick_spam_enabled = !brick_spam_enabled

func _physics_process(delta: float) -> void:
	if brick_spam_enabled:
		Audio.play_1d_sound(preload("res://engine/objects/bumping_blocks/_sounds/break.wav"))


func on_alrighty() -> void:
	Audio.play_1d_sound(preload("res://engine/objects/players/prefabs/sounds/mario/checkpoint_1.ogg"))
