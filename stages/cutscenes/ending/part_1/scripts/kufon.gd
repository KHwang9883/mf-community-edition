extends GravityBody2D

@onready var kufon = $Kufon
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

func _ready():
	collided_floor.connect(func():
		if speed_previous.y > 10:
			speed.y = speed_previous.y / -3
			audio_stream_player_2d.play()
		#else:
		#	speed.y = Vector2.ZERO
	)

func _physics_process(delta):
	motion_process(delta)
	if speed.x < 0.0:
		speed.x = move_toward(speed.x, 0.0, delta * 50)
	if !speed.is_zero_approx():
		kufon.rotation += delta * (speed.x / 4)
	
