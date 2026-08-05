extends Node

@export var custom_go_resume_scene: String
@onready var timer: Timer = $Timer #Timer
@onready var bowser = $"../Bowser"

var trail_timer: float
var gifted: int

func _ready() -> void:
	Scenes.custom_scenes.game_over.custom_resume_scene = custom_go_resume_scene

func _physics_process(delta: float) -> void:
	# Trail effect
	if !is_instance_valid(bowser) || bowser.health == 0: return
	if trail_timer > 0.0: trail_timer -= 1 * Thunder.get_delta(delta)
	if trail_timer <= 0.0:
		trail_timer = 1.5
		if bowser.tween_hurt && bowser.tween_hurt.is_running():
			return
		Effect.trail(
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
	Scenes.current_scene.enable_restart_in_pause = false


func add_life() -> void:
	if gifted > 23: return
	if !Thunder._current_player:
		return
	Thunder.add_lives(1)
	gifted += 1
	var _sfx = CharacterManager.get_sound_replace(Data.LIFE_SOUND, Data.LIFE_SOUND, "1up", false)
	Audio.play_1d_sound(_sfx, false)


func _on_level_completed() -> void:
	Scenes.custom_scenes.game_over.custom_resume_scene = ""
