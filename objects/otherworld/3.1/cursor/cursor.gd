extends Node2D

signal scripted_move_ended
signal scripted_move_waiting

const SMOKE = preload("res://engine/objects/effects/smoke/smoke.tscn")

@export var speed: float = 50
@export var scripted_move: bool = false
@export var scripted_wait_to_end_sec: float = 0.6
@export var scripted_disable_killing: bool = false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var enemy_attacked: Node = $Body/EnemyAttacked

var _moving_scripted: bool
var _marker_pos: Vector2
var _moving_script_timer: float

func _ready() -> void:
	if scripted_move:
		_marker_pos = $Marker2D.global_position
		_moving_scripted = true
		if scripted_disable_killing:
			enemy_attacked.killing_enabled = false

func _physics_process(delta: float) -> void:
	if _moving_scripted:
		sprite.animation = &"chase"
		global_position = global_position.move_toward(
			_marker_pos,
			speed * (delta * 2)
		)
		if global_position.is_equal_approx(_marker_pos):
			if _moving_script_timer == 0:
				scripted_move_waiting.emit()
			_moving_script_timer += delta
			if _moving_script_timer > scripted_wait_to_end_sec:
				_moving_scripted = false
				scripted_move_ended.emit()
				if scripted_disable_killing:
					enemy_attacked.killing_enabled = true
		return
	
	var player: Player = Thunder._current_player
	if !player:
		sprite.play(&"default")
		return
	
	var dir := signi(Thunder.Math.look_at(global_position, player.global_position, global_transform))

	if player.direction == dir:
		sprite.animation = &"chase"
		global_position = global_position.move_toward(
			player.global_position,
			speed * (delta * 2)
		)
	else:
		sprite.play(&"default")
		
