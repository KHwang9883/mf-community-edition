extends "res://engine/objects/enemies/cheeps/jumping_cheeps_generator.gd"

@export var chance_every_stopped_sec: float = 0.2

func _time() -> void:
	var player = Thunder._current_player
	var is_moving: bool = player && player.speed.x > 20
	await get_tree().create_timer(chance_every_sec if is_moving else chance_every_stopped_sec, false).timeout
	_time()
	
	if !enabled: return
	
	if get_tree().get_node_count_in_group("obj_by_" + str(get_instance_id())) >= max_on_screen:
		return
	Thunder.view.cam_border()
	var to_pos = Vector2(Thunder.view.border.end) + Vector2(32, randi_range(16, 316))
	
	
	var fish = cheep_scene.instantiate()
	fish.global_position = to_pos
	fish.reset_physics_interpolation()
	fish.speed.x = randi_range(speed_min.x, speed_max.x)
	fish.speed.y = randi_range(speed_min.y, speed_max.y)
	fish.add_to_group("obj_by_" + str(get_instance_id()))
	Scenes.current_scene.add_child(fish)
