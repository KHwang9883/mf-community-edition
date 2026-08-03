extends "res://engine/objects/powerups/poisonous_mushroom/poisonous_mushroom.gd"
@onready var wings: AnimatedSprite2D = get_node_or_null("Wings")
@onready var wings_2: AnimatedSprite2D = get_node_or_null("Wings2")

func _physics_process(delta: float) -> void:
	var player: Player = Thunder._current_player
	if !supply_behavior:
		if !appear_distance:
			var to_pos: Vector2
			if player:
				to_pos = player.global_position
			global_position = global_position.move_toward(to_pos, delta * 118.75)
			modulate.a = 1
			z_index = 5
			if wings && wings_2:
				wings.show()
				wings_2.show()
		else:
			appear_process(Thunder.get_delta(delta))
	
	if !player: return
	if player.warp != Player.Warp.NONE: return
	var overlaps: bool = body.overlaps_body(player)
	if overlaps && !one_overlap:
		collect()
	if !overlaps && one_overlap:
		one_overlap = false
