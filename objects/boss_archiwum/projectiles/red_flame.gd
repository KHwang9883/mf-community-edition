extends "res://engine/objects/enemies/spikes/spike.gd"

var velocity: float
var static_flame = preload("res://objects/boss_archiwum/projectiles/flame_static.tscn")
var flame_timing: float = 0.1
@export var enable_statics: bool = true

func _ready() -> void:
	_delay()


func _physics_process(delta: float) -> void:
	super(delta)
	global_position.x += velocity * Thunder.get_delta(delta)


func _delay() -> void:
	if !enable_statics: return
	
	await get_tree().create_timer(randf_range(flame_timing, flame_timing + 0.2), false).timeout
	
	if global_position.x < 64 + 16: return
	if global_position.x > 576 - 16: return
	
	NodeCreator.prepare_2d(static_flame, Scenes.current_scene).create_2d().call_method(func(flame: Area2D):
		flame.global_position = global_position + Vector2(0, 18)
	)
	
	_delay()
