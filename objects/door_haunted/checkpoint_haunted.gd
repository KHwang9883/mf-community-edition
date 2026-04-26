extends "res://engine/objects/core/checkpoint/checkpoint.gd"

func activate() -> void:
	super()
	await get_tree().create_timer(0.6, false, true).timeout
	var tw = create_tween().set_parallel(true)
	tw.tween_property(text, ^"modulate:a", 0.0, 0.6)
	tw.tween_property($Sign, ^"modulate:a", 0.0, 0.6)
	
