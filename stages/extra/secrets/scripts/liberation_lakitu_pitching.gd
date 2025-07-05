extends ByNodeScript


func _ready() -> void:
	var min_speed: Vector2 = vars.get(&"speed_min", Vector2.ZERO)
	var max_speed: Vector2 = vars.get(&"speed_max", Vector2.ZERO)
	node.set(&"belongs_to", Data.PROJECTILE_BELONGS.ENEMY)
	if node is GravityBody2D:
		var positivity: int = Thunder.rng.get_randi_range(0, 1)
		if positivity == 0: positivity = -1
		node.vel_set(Vector2(
			Thunder.rng.get_randf_range(min_speed.x, max_speed.x) * positivity,
			Thunder.rng.get_randf_range(min_speed.y, max_speed.y)
		))
