extends AnimatedSprite2D

var velocity: Vector2 = Vector2.ZERO

@onready var initial_position := global_position

func _ready() -> void:
	_jump()
	_speak()

func _physics_process(delta: float) -> void:
	velocity.y += 625 * delta
	global_position += velocity * delta
	
	if global_position.y >= initial_position.y:
		global_position.y = initial_position.y
		velocity.y = 0
	
	animation = "default" if is_zero_approx(velocity.y) else "jump"

func _jump() -> void:
	await get_tree().create_timer(randf_range(0, 1), false).timeout
	if is_zero_approx(velocity.y):
		velocity.y = randf_range(-200, -400)
	_jump()

func _speak() -> void:
	await get_tree().create_timer(randf_range(0, 15), false).timeout
	var text = preload("res://stages/cutscenes/ending/part_2/objects/mario_text/mario_text.tscn").instantiate()
	text.global_position = global_position - Vector2(0, 64)
	Scenes.current_scene.add_child(text)
	_speak()
