extends Node

@export var max_enemies: int = 99
@export var life_time_sec: float = 15
@onready var timer = $Timer

const GOOMBA = preload("res://engine/objects/enemies/goombas/goomba.tscn")


func _ready() -> void:
	timer.timeout.connect(_spawn_goomba)


func _spawn_goomba() -> void:
	if !is_instance_valid(Thunder._current_player) || Thunder._current_player.completed:
		return
	if get_tree().get_node_count_in_group(&"party_spawned_enemy") >= max_enemies:
		return
	
	var new_position_x: float = Thunder.view.border.position.x
	await get_tree().create_timer(0.3, false).timeout
	if !is_instance_valid(Thunder._current_player) || Thunder._current_player.completed:
		return
	Thunder.view.cam_border()
	var calculated_position: Vector2 = Vector2(new_position_x + 520, Thunder.view.border.position.y)
	var rand_pos_offset: float = randi_range(0, 200)
	calculated_position.x += rand_pos_offset
	
	var direct_space: PhysicsDirectSpaceState2D = Scenes.current_scene.get_world_2d().direct_space_state
	var dir_space_params = PhysicsPointQueryParameters2D.new()
	dir_space_params.collision_mask = 32 # Mask 6, block_for_enemies
	dir_space_params.position = calculated_position
	var _intersection := direct_space.intersect_point(dir_space_params, 16)
	for i in _intersection:
		if is_instance_valid(i.get("collider", null)):
			print(i)
			return
	
	var instance = GOOMBA.instantiate()
	instance.life_time = life_time_sec
	instance.position = calculated_position
	instance.reset_physics_interpolation()
	instance.speed.y = 1000
	instance.add_to_group(&"party_spawned_enemy")
	instance.max_falling_speed = 625
	
	Scenes.current_scene.add_child(instance)
