extends AnimatedSprite2D

var velocity: Vector2 = Vector2.ZERO

@onready var initial_position := global_position

func _ready() -> void:
	_jump()
	_speed_randomizer()

func _physics_process(delta: float) -> void:
	velocity.y += 625 * delta
	global_position += velocity * delta
	
	if global_position.y >= initial_position.y:
		global_position.y = initial_position.y
		velocity.y = 0
	
	Thunder.view.cam_border()
	if global_position.x < Thunder.view.border.position.x - 32:
		queue_free()

func _speed_randomizer() -> void:
	velocity.x = randi_range(-180, -30)
	await get_tree().create_timer(randf_range(0.1, 0.5), false).timeout
	_speed_randomizer()

func _jump() -> void:
	await get_tree().create_timer(randf_range(0, 4), false).timeout
	if is_zero_approx(velocity.y):
		velocity.y = randf_range(-200, -400)
		Audio.play_sound(preload("res://stages/cutscenes/ending/part_3/sounds/bobas_mario_jump.wav"), self, true)
	_jump()
