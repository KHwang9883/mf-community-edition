extends Area2D

@export var to_dir: int = 1

func _physics_process(delta: float) -> void:
	var player: Player = Thunder._current_player
	if !player: return
	if overlaps_body(player) && !player.is_starman() && !player.is_invincible() && get_parent().dir == to_dir:
		player.hurt()
