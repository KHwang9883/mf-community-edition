extends Node2D

enum FacingMethod {
	LOOK_AT_PLAYER,
	X_SINE,
	Y_COSINE
}

@export_group("Physics")
@export var amplitude: Vector2 = Vector2(50, 50)
@export_range(0, 360, 0.01, "suffix: °") var phase_x: float
@export_range(0, 360, 0.01, "suffix: °") var phase_y: float
@export var random_phase: bool:
	set(rph):
		random_phase = rph
		if random_phase:
			phase_x = Thunder.rng.get_randf_range(0, 360)
			phase_y = phase_x
@export var frequency_x: float = 1
@export var frequency_y: float = 1
@export_group("Sprite")
@export var sprite_path: NodePath
@export var facing_method: FacingMethod = FacingMethod.LOOK_AT_PLAYER

var dir: int
var facing: float

@onready var center: Vector2 = position

func _ready() -> void:
	_physics_process(0)


func _physics_process(delta: float) -> void:
	position.x = Thunder.Math.oval(center, amplitude, deg_to_rad(phase_x)).x
	position.y = Thunder.Math.oval(center, amplitude, deg_to_rad(phase_y)).y
	phase_x = wrapf(phase_x + frequency_x * Thunder.get_delta(delta), 0, 360)
	phase_y = wrapf(phase_y + frequency_y * Thunder.get_delta(delta), 0, 360)
	
	if !sprite_path || !has_node(sprite_path):
		return
	var sprite = get_node(sprite_path)
	
	match facing_method:
		FacingMethod.LOOK_AT_PLAYER:
			var player: Player = Thunder._current_player
			if player:
				facing = Thunder.Math.look_at(global_position, player.global_position, global_transform)
		FacingMethod.X_SINE:
			facing = -sin(deg_to_rad(phase_x))
		FacingMethod.Y_COSINE:
			facing = cos(deg_to_rad(phase_y))
	dir = sign(facing)
	
	if &"flip_h" in sprite:
		sprite.flip_h = (facing < 0 && facing != 0)
