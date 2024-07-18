extends Node

@onready var timer: Timer = $Timer # Timer
@onready var coin_timer: Timer = $CoinTimer # CoinTimer
@onready var timer_2 = $Timer2
@onready var pipe_timer = $PipeTimer

@onready var enemy_spawners: Node2D = $"../EnemySpawners"
@onready var coin_pipe = $"../CoinPipe"
@onready var status: AnimatedSprite2D = $"../CanvasLayer/Status"
@onready var starter: Node2D = $"../START/Node2D"
@onready var life_nodes: Array[Node2D] = [
	$"../CanvasLayer/Node2D",
	$"../CanvasLayer/Node2D2",
	$"../CanvasLayer/Node2D3"
]

var timer_left: int = 5

const enemy_array: Array = [
	preload("res://engine/objects/enemies/goombas/goomba.tscn"),
	preload("res://engine/objects/enemies/goombas/goomba.tscn"),
	preload("res://stages/extra/minix/objects/koopa_green_minix.tscn"),
	preload("res://engine/objects/enemies/spinies/spiny_red.tscn"),
	preload("res://stages/extra/minix/objects/coin_walking.tscn")
]
const COIN_FROM_PIPE = preload("res://stages/extra/minix/objects/coin_from_pipe.tscn")

func _ready() -> void:
	#if "map_id" in Data.values:
	#	starter.map_id = Data.values.map_id
	#	starter._on_map_changed_to(starter.map_id)
	#else:
	#	starter._on_map_changed_to(starter.map_id)
	Data.reset_all_values()


func _on_game_started() -> void:
	(func():
		process_mode = Node.PROCESS_MODE_INHERIT
		Data.reset_all_values()
		timer.timeout.connect(_on_timeout)
		coin_timer.timeout.connect(Data.add_score.bind(1))
		pipe_timer.timeout.connect(_on_pipe_timeout)
		
		for i in len(life_nodes):
			var life_count: int = starter.current_map.life_count
			if life_count <= i:
				life_nodes[i].visible = false
		if !starter.current_map.stop_music_on_death:
			Thunder._current_player.death_stop_music = false
	).call_deferred()


func _physics_process(delta: float) -> void:
	if !OS.is_debug_build(): return
	
	if Input.is_action_just_pressed("ui_page_up"):
		timer.wait_time = 0.4


func _on_timeout() -> void:
	new_random_enemy(int(!timer_2.is_stopped()))
	timer.wait_time = max(0.4, timer.wait_time - 0.04)


func pick_random_marker() -> Vector2:
	var children: Array = enemy_spawners.get_children()
	var random: int = randi_range(0, children.size() - 1)
	return children[random].global_position


func new_random_enemy(index: int = 0) -> void:
	var picked = enemy_array[index] if index else enemy_array.pick_random()
	var enemy = picked.instantiate()
	enemy.position = pick_random_marker()
	enemy.force_direction = -1 + 2 * round(randf())
	if starter.map_id == 2:
		enemy.gravity_scale /= 2
	Scenes.current_scene.add_child.call_deferred(enemy)


func _on_pipe_timeout() -> void:
	coin_pipe.position = Vector2(randi_range(80, 560), 528)
	Audio.play_sound(preload("res://engine/objects/bumping_blocks/_sounds/appear.wav"), coin_pipe, false)
	
	var tw = create_tween()
	tw.tween_property(coin_pipe, "position:y", 432, 1.5)
	tw.tween_callback(_pipe_burst)


func _pipe_burst() -> void:
	var i: int = 20
	while i > 0:
		await get_tree().create_timer(0.05, false).timeout
		i -= 1
		
		var coin_inst = COIN_FROM_PIPE.instantiate()
		coin_inst.position = coin_pipe.position
		coin_inst.speed = Vector2(randf_range(-250, 250), randf_range(-500, -350))
		Scenes.current_scene.add_child(coin_inst)
		var tw = coin_inst.create_tween()
		tw.tween_property(coin_inst, "scale", Vector2.ONE, 0.2)
		tw.tween_callback(coin_inst.get_node("Area2D").set_collision_mask_value.bind(1, true))
		
		if i == 0:
			create_tween().tween_property(coin_pipe, "position:y", 432+96, 1.5)


func _on_mario_damaged_to(lives: int) -> void:
	life_nodes[lives].get_node("AnimatedSprite2D").fade_out()
