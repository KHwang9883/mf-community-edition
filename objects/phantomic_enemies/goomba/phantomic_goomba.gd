extends GeneralMovementBody2D

const BALL: PackedScene = preload("../phantomic_ball/phantomic_ball.tscn")

@export_category("Phantomic Goomba")
@export var shooting_interval: float = 3
@export var ball_speed: float = 300

@onready var interval: Timer = $Interval



func _ready() -> void:
	interval.start(shooting_interval)


func _on_shooting() -> void:
	var spx: float = speed.x
	speed.x = 0
	sprite_node.play(&"shoot")
	await sprite_node.animation_finished
	# Shooting
	var shoot: Vector2 = Vector2.UP.rotated(PI/6)
	for i in 3:
		NodeCreator.prepare_2d(BALL, self).bind_global_transform().create_2d().call_method(
			func(ball: Projectile) -> void:
				ball.vel_set(shoot * ball_speed)
		)
		shoot = shoot.rotated(-PI/6)
	
	sprite_node.play(&"default")
	speed.x = spx
