extends AnimatedSprite2D


func _ready() -> void:
	modulate.a = 0
	_loop()

func _loop() -> void:
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 1, 2)
	
	await get_tree().create_timer(4.5, false).timeout
	
	var tw2 = create_tween()
	tw2.tween_property(self, "modulate:a", 0, 2)
	
	await tw2.finished
	
	if frame >= sprite_frames.get_frame_count("default") - 1:
		frame = 0
	else:
		frame += 1
	
	_loop()
