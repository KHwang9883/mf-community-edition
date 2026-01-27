extends Area2D

@export var set_gravity_scale: float = 0.5
@export var set_max_falling_speed: float = 1000

func _ready() -> void:
	body_entered.connect(func(body: Node2D):
		if !"gravity_scale" in body:
			return
		if !body is GeneralMovementBody2D: return
		body.gravity_scale = set_gravity_scale
		body.max_falling_speed = set_max_falling_speed
	)
