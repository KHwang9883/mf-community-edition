extends GeneralMovementBody2D

const ZAZHIGALKA_ZVUKI = preload("res://objects/volcano/bullet_bill_perdit/sfx/zazhigalka-zvuki.wav")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_sprite_2d_2: AnimatedSprite2D = $AnimatedSprite2D2


var _adding = 0

func _ready() -> void:
	super()
	await get_tree().create_timer(0.2, false, true).timeout
	_adding = 200
	Audio.play_sound(ZAZHIGALKA_ZVUKI, self)
	animated_sprite_2d.play(&"default")
	animated_sprite_2d_2.play(&"default")
	animated_sprite_2d.animation_finished.connect(
		func():
			animated_sprite_2d.play(&"firing")
			animated_sprite_2d_2.play(&"firing"),
		CONNECT_ONE_SHOT
	)


func _physics_process(delta: float) -> void:
	super(delta)
	if has_meta(&"added_speed_angle"):
		speed += _adding * delta * get_meta(&"added_speed_angle", Vector2.RIGHT)
		return
	speed.x += _adding * delta * dir
