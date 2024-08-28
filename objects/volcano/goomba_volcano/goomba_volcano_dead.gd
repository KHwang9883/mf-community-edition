extends Node2D

@onready var iron_goomba_debris_1: Sprite2D = $"Iron-goomba-debris-1"
@onready var iron_goomba_debris_2: Sprite2D = $"Iron-goomba-debris-2"

var vel_1: Vector2
var vel_2: Vector2


func _ready() -> void:
	vel_1 = Vector2(randf_range(-250, -50), randf_range(-250, -50))
	vel_2 = Vector2(randf_range(250, 50), randf_range(-250, -50))
	await get_tree().create_timer(4, false, true).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	iron_goomba_debris_1.position += vel_1 * delta
	iron_goomba_debris_2.position += vel_2 * delta
	
	vel_1.y += 1000 * delta
	vel_2.y += 1000 * delta
	
	iron_goomba_debris_1.rotation_degrees -= 400 * delta
	iron_goomba_debris_2.rotation_degrees += 400 * delta
