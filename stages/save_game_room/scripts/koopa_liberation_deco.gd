extends Sprite2D

func _physics_process(delta: float) -> void:
	var player: Player = Thunder._current_player
	if player:
		var facing: float
		facing = Thunder.Math.look_at(global_position, player.global_position, global_transform)
		flip_h = (facing < 0 && facing != 0)
