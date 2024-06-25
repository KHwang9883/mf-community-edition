extends AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	if Thunder.view.get_pos_in_screen(self).y < -32:
		global_position.y += 480 + 64
	
	if Thunder.view.get_pos_in_screen(self).y > 480 + 32:
		global_position.y -= 480 + 64
	
	if Thunder.view.get_pos_in_screen(self).x < 64:
		global_position.x += 640 + 128
	
	if Thunder.view.get_pos_in_screen(self).x > 640 + 64:
		global_position.x -= 640 + 128
