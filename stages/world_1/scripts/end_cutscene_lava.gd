extends Node

const CASTLE_CRASH = preload("res://engine/scenes/castle_cutscene/sounds/castle_crash.wav")

@onready var lava_end_cutscene: LevelCutscene = $".."
@onready var mario: Player = Thunder._current_player

var _transition: bool = false


func _ready() -> void:
	mario.jump(400)
	mario.collision = false
	mario.completed = true
	Audio.stop_all_sounds()
	var _sndfx: AudioStream = mario.suit.physics_config.sound_jump[randi_range(0, len(mario.suit.physics_config.sound_jump) - 1)]
	Audio.play_1d_sound(_sndfx)

func _physics_process(delta: float) -> void:
	if mario.speed.y > 0:
		mario.collision = true
	
	mario.direction = 1
	
	if !mario.is_on_floor():
		mario.speed.x = 60
	else:
		mario.speed.x += 500 * delta
	
	if mario.global_position.x > 500 && !_transition:
		Audio.play_1d_sound(CASTLE_CRASH, true, { "ignore_pause": true })
		_transition = true
		Thunder._current_camera.shock(1.5, Vector2(4, 4))
		get_tree().call_group(&"1-4_castle", &"set_falling")
		
		await get_tree().create_timer(1.5, false).timeout
		lava_end_cutscene.end()
