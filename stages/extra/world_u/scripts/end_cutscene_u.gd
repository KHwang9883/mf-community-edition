extends Node

const CASTLE_BRICK = preload("res://engine/scenes/castle_cutscene/objects/castle_brick.tscn")
const CASTLE_SMOKE = preload("res://engine/scenes/castle_cutscene/objects/castle_smoke.tscn")
const EXPLOSION = preload("res://engine/objects/effects/explosion/explosion.tscn")

const JUMP = preload("res://engine/objects/players/prefabs/sounds/jump.wav")
const BREAK = preload("res://engine/objects/bumping_blocks/_sounds/break.wav")
const STOMP = preload("res://engine/objects/enemies/_sounds/stomp.wav")

@onready var player: Player = Thunder._current_player
@onready var castle: Sprite2D = $"../Castle"
@onready var castle_big_2: Sprite2D = $"../CastleBig2"
@onready var castle_big_3: Sprite2D = $"../CastleBig3"
@onready var castle_full_broken_deluxe: Sprite2D = $"../CastleFullBrokenDeluxe"

@onready var castle_end_marker = $"../CastleEndMarker"
@onready var castle_pos: float = castle.position.x
@onready var label: Label = $"../Sign/Label"

@onready var init_pos = castle.global_position + Vector2.ZERO

var _player_speed: float = 0.0
var _move_to_speed: float = 325
var _moving: bool = false
var _destroying: bool = false
var _finished: float = 0.0

var _step: int = 0


func _ready() -> void:
	label.text %= CharacterManager.get_character_display_name()
	await get_parent().ready
	player = Thunder._current_player
	player.completed = true
	await get_tree().create_timer(0.5, false, true).timeout
	var tw = create_tween()
	tw.tween_property(player, "modulate:a", 1.0, 1.0)
	await get_tree().create_timer(0.5, false, true).timeout
	_moving = true
	await get_tree().create_timer(2.5, false, true).timeout
	
	Audio.play_1d_sound(preload("res://engine/objects/players/prefabs/sounds/powerup.wav"), false, {pitch = 0.75})
	player.change_suit(CharacterManager.get_suit("super"), true, true)
	player.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	player.position.y -= 72
	player.reset_physics_interpolation()
	player.scale = Vector2.ONE * 6
	_move_to_speed = 0
	
	await get_tree().create_timer(1.5, false, true).timeout
	
	_move_to_speed = -250
	player.direction = -1


func _physics_process(delta: float) -> void:
	if _moving && _finished < 500:
		player.speed.x = _player_speed
		_player_speed = move_toward(_player_speed, _move_to_speed, delta * 250)
		if _player_speed != 0:
			@warning_ignore("narrowing_conversion")
			player.direction = signi(_player_speed)
		if player.position.x > 704 && player.speed.x > 1:
			if _step == 0:
				player.speed.x = 0
				_player_speed = 0
			else:
				_finished = 500
	
		if _player_speed < 0:
			if player.position.x < 480 && _step == 0:
				_step = 1
				var conf: PlayerConfig = player.suit.physics_config
				var _sndfx: AudioStream = conf.sound_jump[randi_range(0, len(conf.sound_jump) - 1)]
				Audio.play_sound(_sndfx, player, false)
				
				player.jump(-700)
				player.coyote_time = 0.0
				player._has_jumped = true
			elif player.position.x < 208 && _step == 1:
				_step = 2
				_move_to_speed = 325
				_player_speed += 100
				var expl = EXPLOSION.instantiate()
				expl.position = Vector2(176, 224)
				expl.scale = Vector2.ONE * 6
				expl.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				var expl2 = expl.duplicate()
				add_child(expl)
				add_child(expl2)
				expl2.global_position = Vector2(176, 336)
				expl2.reset_physics_interpolation()
				
				expl.z_index = 10
				player.jump(200)
				castle_big_3.hide()
				castle_big_2.hide()
				castle.hide()
				castle_full_broken_deluxe.show()
				_brick_particles()
				Audio.play_1d_sound(STOMP, false)
				Thunder._current_camera.shock_smooth(20, 5)
				run_while(_smoke_particles, 0.02)
				
				var break_sound = CharacterManager.get_sound_replace(BREAK, BREAK, "block_break", false)
				Audio.play_1d_sound(break_sound, false)
	
	if _destroying:
		castle.position.y += delta * 50
	if _finished > 2.0 && _finished < 999:
		_finished = 1000
		Scenes.current_scene.end()
	
	#if _shaking:
	#	castle.global_position = init_pos + Vector2(randi_range(-2, 2), randi_range(0, 2))
	


func run_while(callable: Callable, repeat_delay: float) -> void:
	if _finished: return
	callable.call()
	await get_tree().create_timer(repeat_delay, false, false, true).timeout
	run_while(callable, repeat_delay)


func _brick_particles() -> void:
	var brick = CASTLE_BRICK.instantiate()
	brick.position = castle_end_marker.position + Vector2(randi_range(-145, 145), 0)
	brick.reset_physics_interpolation()
	brick.speed = Vector2(randf_range(-4.0, 4.0), randi_range(-11, -6))
	Scenes.current_scene.add_child(brick)
	for i in 10:
		var _br = brick.duplicate()
		_br.position = castle_end_marker.position + Vector2(randi_range(-145, 145), 0)
		_br.reset_physics_interpolation()
		_br.speed = Vector2(randf_range(-4.0, 4.0), randi_range(-11, -6))
		Scenes.current_scene.add_child(_br)


func _smoke_particles() -> void:
	var smoke = CASTLE_SMOKE.instantiate()
	smoke.position = castle_end_marker.position + Vector2(randi_range(-157, 157), 0)
	smoke.reset_physics_interpolation()
	smoke.y_modifier = randi_range(-10, 10)
	smoke.rotation_speed = randi_range(-90, 90)
	Scenes.current_scene.add_child(smoke)
