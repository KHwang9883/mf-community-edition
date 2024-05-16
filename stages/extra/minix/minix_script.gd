extends Node

@onready var timer: Timer = Timer.new() # Timer
@onready var enemy_spawners: Node2D = $"../EnemySpawners"
var timer_left: int = 5
var lives: int = 1

const enemy_array: Array = [
	preload("res://engine/objects/enemies/goombas/goomba.tscn"),
	preload("res://engine/objects/enemies/goombas/goomba.tscn"),
	preload("res://engine/objects/enemies/koopas/koopa_green.tscn"),
	preload("res://engine/objects/enemies/spinies/spiny_red.tscn"),
	preload("res://engine/objects/enemies/spinies/coin_walking.tscn")
]

func _ready() -> void:
	timer.start(5)
	await get_tree().create_timer(3.0, false)
	

func _physics_process(delta: float) -> void:
	pass


func pick_random_marker() -> Vector2:
	var children: Array = enemy_spawners.get_children()
	var random: int = randi_range(0, children.size() - 1)
	return children[random].global_position


func new_random_enemy() -> void:
	
