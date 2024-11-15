extends Sprite2D

func _physics_process(delta: float) -> void:
	flip_h = Thunder._current_player.global_position > global_position
