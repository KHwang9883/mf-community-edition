extends Node2D

@onready var lava_top_hud = $"../HUD/LavaTopHUD"
@onready var lava_hud = $"../HUD/LavaHUD"
@onready var lava_hud_animation: AnimationPlayer = $"../HUD/LavaHUD/Animation"
@onready var timer: Timer = $Timer # Timer
@onready var static_body_2d = $"../ParallaxBackground/ParallaxLayer/StaticBody2D"
@onready var sound: AudioStreamPlayer2D = $Lava/SoundRising
@onready var sound_accel: AudioStreamPlayer2D = $Lava/SoundAccel

var rising_step: int
var started_rising: bool
var lava_speed: float
var player: Player


func _ready():
	player = Thunder._current_player
	timer.timeout.connect(func():
		_start_rising()
	)

func _physics_process(delta):
	if is_instance_valid(player): 
		if player.completed && is_instance_valid(static_body_2d):
			static_body_2d.queue_free()
	
		if player.global_position.y < -960:
			_start_rising()
		
		match rising_step:
			0 when player.global_position.y < -3040:
				rising_step = 1
				_accelerate()
			1 when player.global_position.y < -4544:
				rising_step = 2
				_accelerate()
			2 when player.global_position.y < -5952:
				rising_step = 3
				_accelerate()
			3 when player.global_position.y < -6944:
				rising_step = 4
				_accelerate()
			
	
	global_position.y += lava_speed * delta
	
	if is_instance_valid(player):
		lava_hud.position.y = lava_top_hud.position.y + (global_position.y - player.global_position.y) / 20
		
		var cam := get_viewport().get_camera_2d()
		if is_instance_valid(cam):
			if player.is_on_floor() && !is_equal_approx(cam.offset.y, 8) && player.global_position.y < 0 && player.global_position.y > -7360:
				cam.offset.y = move_toward(cam.offset.y, 8, 5 * delta)
			elif !is_zero_approx(cam.offset.y):
				cam.offset.y = move_toward(cam.offset.y, 0, 50 * delta)



func _start_rising() -> void:
	if started_rising:
		return
	
	started_rising = true
	
	if !sound.finished.is_connected(sound.play):
		sound.finished.connect(sound.play)
		sound.play()
	
	if is_instance_valid(timer):
		timer.queue_free()
	
	lava_hud_animation.play("warning_accelerated")
	
	lava_speed = -50


func _accelerate() -> void:
	create_tween().tween_property(self, "lava_speed", lava_speed - 37.5, 1)
	sound_accel.play()
	lava_hud_animation.play("warning_accelerated")


func koniec_gry() -> void:
	lava_hud.material = null
	
	var tw = create_tween().set_parallel()
	tw.tween_property(self, "lava_speed", 0.0, 0.5)
	tw.tween_property(lava_hud, "modulate:a", 0, 2)
	tw.tween_property(lava_top_hud, "modulate:a", 0, 2)
	
	if sound.finished.is_connected(sound.play):
		sound.finished.disconnect(sound.play)
		create_tween().tween_property(sound, "volume_db", -40, 0.5).finished.connect(sound.stop)
	
	if is_instance_valid(timer):
		timer.stop()


func _on_animation_animation_finished(_anim_name: StringName) -> void:
	lava_hud_animation.play("RESET")
