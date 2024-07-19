extends Node2D

@onready var initial_pos: Vector2 = position
@export var multiplicator: float = 5
@export var speed: float = 300
var counter: float

func _physics_process(delta: float) -> void:
	counter += speed * delta
	position = initial_pos + Vector2(0, sin(deg_to_rad(counter)) * multiplicator)
