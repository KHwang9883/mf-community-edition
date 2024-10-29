extends Node

@onready var lava_end_cutscene: LevelCutscene = $".."
@onready var mario: Player = Thunder._current_player

var _transition: bool = false


func _ready() -> void:
	mario.jump(400)
	mario.collision = false
	Audio.play_1d_sound(mario.suit.physics_config.sound_jump)

func _physics_process(delta: float) -> void:
	if mario.speed.y > 0:
		mario.collision = true
	
	mario.direction = 1
	
	if !mario.is_on_floor():
		mario.speed.x = 60
	else:
		mario.speed.x += 500 * delta
	
	if mario.global_position.x > 500 && !_transition:
		Audio.play_1d_sound(preload("res://sfx/IntroCastleCrush2.wav"), true, { "ignore_pause": true })
		_transition = true
		Thunder._current_camera.shock(1.5, Vector2(4, 4))
		get_tree().call_group(&"1-4_castle", &"set_falling")
		
		await get_tree().create_timer(1.5, false).timeout
		lava_end_cutscene.end()
