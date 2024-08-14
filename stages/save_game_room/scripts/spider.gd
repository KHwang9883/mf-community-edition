extends AnimatedSprite2D


func _ready() -> void:
	_timer()

func _timer() -> void:
	await get_tree().create_timer(randi_range(1, 4) / 2.0, false).timeout
	var target_pos = position.y
	target_pos += randi_range(-20, 20)
	target_pos = clamp(target_pos, -30, 2)
	
	var tw = create_tween()
	tw.tween_property(self, "position:y", target_pos, 0.2)
	_timer()
