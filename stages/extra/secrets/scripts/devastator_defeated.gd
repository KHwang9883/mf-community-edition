extends Node

@export var path_to_level_2_1: String = "res://stages/world_2/level_2-1.tscn"
@onready var timer: Timer = $Timer #Timer
@onready var bowser = $"../Bowser"

var trail_timer: float


func _physics_process(delta: float) -> void:
	# Trail effect
	if !is_instance_valid(bowser) || bowser.health == 0: return
	if trail_timer > 0.0: trail_timer -= 1 * Thunder.get_delta(delta)
	if trail_timer <= 0.0:
		trail_timer = 1.5
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
	var profile = ProfileManager.current_profile
	if !profile.has_completed(path_to_level_2_1):
		profile.complete_level(path_to_level_2_1)
		ProfileManager.save_current_profile()

func add_life() -> void:
	Thunder.add_lives(1)
	Audio.play_1d_sound(preload("res://engine/objects/players/prefabs/sounds/1up.wav"))
