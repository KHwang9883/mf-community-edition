extends Area2D

func _on_area_entered(area):
	if area.get_parent() is AnimatedSprite2D:
		area.get_parent().speed = -area.get_parent().speed
