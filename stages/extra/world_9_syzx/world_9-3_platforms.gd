extends "res://engine/objects/platform/platform_path.gd"

@export var fall_off_on: int = 2
var _called: bool = false

@onready var path_2d: Path2D = $".."

func _on_path_movement_process(delta: float) -> void:
	if !on_path: return
	if _movement_blocked: return
	
	#var pos: Vector2 = global_position
	# Moving
	if falling_acceleration != 0:
		linear_velocity += falling_direction.normalized() * falling_acceleration * delta
	
	if curve:
		progress += speed * delta
		_sharp_movement()
	
	if falling_acceleration != 0:
		position += linear_velocity * Thunder.get_delta(delta)


func _player_landed(player: Player) -> void:
	super(player)
	if _called: return
	speed = 100
	_called = true
	get_tree().call_group(&"gray_platform", &"_set_speed")
	path_2d._stop_rising()

func fall_off(index: int) -> void:
	if index == fall_off_on:
		falling_acceleration = 200

func _set_speed() -> void:
	speed = 100
