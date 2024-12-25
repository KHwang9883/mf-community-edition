extends Node

@onready var timer: Timer = $Timer #Timer
@onready var bowser = $"../Bowser"

var trail_timer: float


func _physics_process(delta: float) -> void:
	# Trail effect
	if !is_instance_valid(bowser) || bowser.health == 0: return
	if trail_timer > 0.0: trail_timer -= 1 * Thunder.get_delta(delta)
	if trail_timer <= 0.0:
		trail_timer = 1.5
		if bowser.tween_hurt && bowser.tween_hurt.is_running():
			return
		Effect.trail.call_deferred(
			bowser, 
			bowser.sprite.sprite_frames.get_frame_texture(bowser.sprite.animation, bowser.sprite.frame),
			bowser.sprite.position,
			bowser.sprite.flip_h,
			bowser.sprite.flip_v,
			true,
			0.05,
			1.0,
			null,
			-1
		)


func has_hit(hp: int) -> void:
	if hp != 0: return
	timer.start()
	timer.timeout.connect(add_life)


func add_life() -> void:
	Thunder.add_lives(1)
	Audio.play_1d_sound(preload("res://engine/objects/players/prefabs/sounds/1up.wav"))
