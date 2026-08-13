extends Node2D

@export var velocity: Vector2 = Vector2(150, 0)
@export var angle: float = 0
@export var angle_rotate_speed: float = 75
@export var alive_time: float = 4

func _ready() -> void:
	await get_tree().create_timer(alive_time, false, true).timeout
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0, 0.5)
	await tw.finished
	queue_free()

func _physics_process(delta: float) -> void:
	global_position += velocity.rotated(deg_to_rad(angle)) * delta
	angle += angle_rotate_speed * delta
