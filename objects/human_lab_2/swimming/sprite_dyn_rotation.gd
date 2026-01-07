extends AnimatedSprite2D

enum TRACK_MOD{
	NONE,
	TARGET,
	PLAYER
}

@onready var _last_pos: Vector2 = global_position
@export var track_mod: TRACK_MOD
@export var target: Node2D
@export var use_smoothness: bool = false
@export_range(0.0, 10.0, 0.001, "hide_slider", "or_grather") var smoothness: float = 3.0

var _target_angle: float
var _elapsed: float

func _ready() -> void:
	match track_mod:
		TRACK_MOD.NONE:
			track_direction()
		TRACK_MOD.TARGET:
			track_target(target)
		TRACK_MOD.PLAYER:
			track_target(Thunder._current_player)
	
	rotation = _target_angle


func _physics_process(delta: float) -> void:
	match track_mod:
		TRACK_MOD.NONE:
			track_direction()
		TRACK_MOD.TARGET:
			track_target(target)
		TRACK_MOD.PLAYER:
			track_target(Thunder._current_player)		

	if use_smoothness:
		rotation = lerp_angle(rotation, _target_angle, smoothness * delta)
	else:
		rotation = _target_angle
	
	rotation = wrapf(rotation,-PI, PI)
	flip_v = rotation < deg_to_rad(-90) || rotation > deg_to_rad(90) 
	_last_pos = global_position

func track_direction() -> void:
	var delta_pos: Vector2 = _last_pos - global_position
	if delta_pos == Vector2.ZERO: return

	_target_angle = delta_pos.angle()
	
	

func track_target(tracker_node: Node2D) -> void:
	if !tracker_node:
		track_direction()
		return
	
	var delta_pos: Vector2 = tracker_node.global_position - global_position

	_target_angle = delta_pos.angle()
