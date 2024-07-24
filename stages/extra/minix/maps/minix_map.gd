extends Node2D
class_name MinixMap

@export var map_name: String
@export var life_count: int = 1
@export var stop_music_on_death: bool = true
@export var start_again_on_replay: bool = true
@export var game_over_music: Resource
@export var timers_node_path: NodePath = ^"Timers"
@export_group("Enemy Spawn Settings", "enemy")
@export var enemy_gravity_scale: float = 0.5
@export var enemy_max_falling_speed: float = 1000

@export var enemy_array: Array[Resource] = [
	preload("res://engine/objects/enemies/goombas/goomba.tscn"),
	preload("res://engine/objects/enemies/goombas/goomba.tscn"),
	preload("res://stages/extra/minix/objects/koopa_green_minix.tscn"),
	preload("res://engine/objects/enemies/spinies/spiny_red.tscn"),
	preload("res://stages/extra/minix/objects/coin_walking.tscn")
]
@export var enemy_spawners: NodePath = ^"EnemySpawners"

@onready var _enemy_spawners_node: Node2D = get_node(enemy_spawners)
@onready var timer: Timer = get_node(timers_node_path).get_node("Timer")
@onready var timer_2: Timer = get_node(timers_node_path).get_node("Timer2")
@onready var coin_timer: Timer = get_node(timers_node_path).get_node("CoinTimer")


func _ready() -> void:
	while !is_instance_valid(Scenes.custom_scenes.minix_node):
		await get_tree().physics_frame
	if is_instance_valid(Scenes.custom_scenes.minix_node):
		Scenes.custom_scenes.minix_node.game_started.connect(_on_game_started)


func _on_game_started() -> void:
	(func():
		var starter = Scenes.custom_scenes.minix_node
		if starter.current_map != self:
			return
		process_mode = Node.PROCESS_MODE_INHERIT
		Data.reset_all_values()
		Data.values.map_id = starter.map_id
		Data.values.godlikes = 0
		timer.timeout.connect(_on_timeout)
		coin_timer.timeout.connect(_on_coin_timer_timeout)
		timer.start()
		coin_timer.start()
		timer_2.start()
		
		var cur_mus = self if starter.current_music_from_map == -1 else starter.map_paths[starter.current_music_from_map]
		if !cur_mus.stop_music_on_death:
			Thunder._current_player.death_stop_music = false
	).call_deferred()

func _physics_process(delta: float) -> void:
	if !OS.is_debug_build(): return
	var starter = Scenes.custom_scenes.minix_node
	if is_instance_valid(starter) && starter.current_map != self:
		return
	
	if Input.is_action_just_pressed("ui_page_up"):
		timer.wait_time = 0.4
	if Input.is_action_just_pressed("ui_page_down"):
		var enemy = load("res://stages/extra/minix/objects/koopa_shell_green_minix.tscn").instantiate()
		enemy.position = Vector2(608, 384)
		Scenes.current_scene.add_child.call_deferred(enemy)
		enemy.status_swap.call_deferred(false)


func _on_timeout() -> void:
	new_random_enemy(int(!timer_2.is_stopped()))
	timer.wait_time = max(0.4, timer.wait_time - 0.04)


func _on_coin_timer_timeout() -> void:
	Data.add_score(1)
	if !"lasted" in Data.values:
		Data.values.lasted = 0
	Data.values.lasted = ";" + str(int(Data.values.lasted) + 1) + "q"


func pick_random_marker() -> Vector2:
	var children: Array = _enemy_spawners_node.get_children()
	var random: int = randi_range(0, children.size() - 1)
	return children[random].global_position


func new_random_enemy(index: int = 0) -> void:
	var picked = enemy_array[index] if index else enemy_array.pick_random()
	var enemy = picked.instantiate()
	enemy.position = pick_random_marker()
	enemy.force_direction = -1 + 2 * round(randf())
	enemy.gravity_scale = enemy_gravity_scale
	enemy.max_falling_speed = enemy_max_falling_speed
	Scenes.current_scene.add_child.call_deferred(enemy)
	
