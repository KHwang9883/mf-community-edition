extends Node2D

@export var mov_offset: Vector2 = Vector2.ZERO
@export var mov_moving: Vector2 = Vector2.ZERO
@export var offset_speed: float = 0

var _counter: float = 0
var _computed_offset: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	_counter += offset_speed * delta
	
	if get_child_count() == 0: return
	
	var star = get_child(0)
	
	if !is_instance_valid(star): return
	
	star.position.x = sin(_counter) * mov_offset.x + _computed_offset.x
	star.position.y = sin(_counter) * mov_offset.y + _computed_offset.y
	
	_computed_offset += mov_moving * delta
