extends "res://engine/objects/enemies/cheeps/jumping_cheeps_generator.gd"

const CHEEP_YEL_JUMPING = preload("res://stages/extra/world_10_syzx/objects/cheep_yel_jumping.tscn")

@export var chance_every_stopped_sec: float = 0.2
@export var replace_by_yellow_in_advanced: bool = true
@export var random_spawn_min := Vector2i(32, 16)
@export var random_spawn_max := Vector2i(32, 316)
@export var destroy_below_y: float = 560
@onready var _tweak = ProfileManager.current_profile.data.get("advanced_edition", false)

func _time() -> void:
	var player = Thunder._current_player
	var is_moving: bool = player && player.speed.x > 20
	await get_tree().create_timer(chance_every_sec if is_moving else chance_every_stopped_sec, false).timeout
	_time()
	
	if !enabled: return
	
	if get_tree().get_node_count_in_group("obj_by_" + str(get_instance_id())) >= max_on_screen:
		return
	Thunder.view.cam_border()
	var to_pos = Vector2(Thunder.view.border.end) + Vector2(
		randi_range(random_spawn_min.x, random_spawn_max.x),
		randi_range(random_spawn_min.y, random_spawn_max.y)
	)
	
	if to_pos.y > destroy_below_y:
		return
	
	var fish
	if !_tweak || !replace_by_yellow_in_advanced:
		fish = cheep_scene.instantiate()
	else:
		fish = CHEEP_YEL_JUMPING.instantiate()
	fish.global_position = to_pos
	fish.reset_physics_interpolation()
	fish.speed.x = randi_range(speed_min.x, speed_max.x)
	fish.speed.y = randi_range(speed_min.y, speed_max.y)
	fish.life_time = 1.0
	fish.add_to_group("obj_by_" + str(get_instance_id()))
	Scenes.current_scene.add_child(fish)
