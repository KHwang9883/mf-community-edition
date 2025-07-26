extends Sprite2D

func _physics_process(delta: float) -> void:
	var pl = Thunder._current_player
	if !pl: return
	flip_h = pl.global_position > global_position
