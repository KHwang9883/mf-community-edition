extends AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var pl: Player = Thunder._current_player
	if !pl: return
	if !pl.is_holding: return
	flip_h = !pl.sprite.flip_h
