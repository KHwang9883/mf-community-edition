extends Powerup

@export var starman_duration: float = 10

var trail_timer: float = 0

@onready var player = Thunder._current_player
@onready var sprite: AnimatedSprite2D = $Sprite

func _physics_process(delta: float) -> void:
	super(delta)
	if is_on_floor():
		jump(250)
	if !appear_distance:
		sprite.speed_scale = 5
		if SettingsManager.settings.quality == SettingsManager.QUALITY.MIN:
			sprite.rotation_degrees = 0
			return
		sprite.rotation_degrees += 250 * delta
		
		# Trail effect
		if trail_timer > 0.0:
			trail_timer -= 50 * delta
		if trail_timer <= 0.0:
			trail_timer = 1.0
			Effect.trail(
				sprite,
				sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame),
				sprite.position,
				sprite.flip_h,
				sprite.flip_v,
				true,
				0.05,
			)

func collect() -> void:
	if appear_distance: return
	
	if score > 0:
		ScoreText.new(str(score), self)
		Data.add_score(score)
	
	queue_free()
	
	Audio.play_sound(pickup_powerup_sound, self, false, {pitch = sound_pitch})
	player.starman(starman_duration)
	player._starman_runout_played = false
	player._starman_faded = true
