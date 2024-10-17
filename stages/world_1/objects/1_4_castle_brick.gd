extends StaticBody2D

@export var do_rotate: bool = true
@export var rotate_fixed: float = 0.0
@export var delay: float = 0
@onready var init_speed_y: float = randf_range(120, 150)
@onready var rotation_speed: float = randf_range(-12, 12)

var falling: bool = false
var speed_y: float

func _physics_process(delta: float) -> void:
	if !falling: return
	speed_y += init_speed_y * delta
	position.y += speed_y * delta
	if do_rotate:
		rotation_degrees += rotation_speed * delta


func set_falling() -> void:
	if delay > 0:
		await get_tree().create_timer(delay, false).timeout
	
	falling = true
	collision_layer = 0
	if rotate_fixed:
		rotation_speed = rotate_fixed
