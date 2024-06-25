extends Node2D

@onready var starting = $".."
@onready var animated_sprite_2d = $AnimatedSprite2D

var max_counter: float
var counter: float = 0
var speed: float = 0

func _ready() -> void:
	max_counter = randf_range(100, 200)
	_timer()

func _physics_process(delta: float) -> void:
	if !starting.set_looking: return
	
	if counter < max_counter:
		animated_sprite_2d.animation = "look"
	
	counter += delta * 30
	
	if counter > max_counter:
		if animated_sprite_2d.animation != "walk":
			animated_sprite_2d.play("walk")
		animated_sprite_2d.flip_h = true
		speed -= delta * 30
	
	global_position.x += speed * delta

func _timer() -> void:
	await get_tree().create_timer(randf_range(0.3, 0.5), false).timeout
	_timer()
	
	if counter < max_counter && starting.set_looking:
		animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
