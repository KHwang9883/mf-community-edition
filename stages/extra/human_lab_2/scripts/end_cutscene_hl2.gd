extends Node

const ZAMEK_LECI = preload("res://sfx/ZamekLeci.wav")
const FALL = preload("res://engine/objects/enemies/spike_ceiling/sfx/fall.wav")
const SND_LIGHTS_ON = preload("res://stages/extra/human_lab_2/objects/nyn/snd_lights_on.ogg")
const BOWSER_DIED = preload("res://engine/objects/bosses/bowser/sounds/bowser_died.wav")

@onready var player: Player = Thunder._current_player
@onready var castle = $"../Castle"
@onready var castle_end_marker = $"../CastleEndMarker"
@onready var castle_pos: float = castle.position.x
@onready var hugebitch_bottom: Sprite2D = $"../HugebitchBottom"
@onready var hugebitch_top: Sprite2D = $"../HugebitchTop"
@onready var hugebitch: Sprite2D = $"../Hugebitch"
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../Hugebitch/AudioStreamPlayer2D"


var _player_speed: float = 0.0
var _moving: bool = false
var _finished: float = 0.0
var moving_away: bool
@onready var area_2d: Area2D = $"../Area2D"
@onready var color_rect: ColorRect = $"../CanvasLayer/ColorRect"

func _ready() -> void:
	hugebitch.hide()
	await get_parent().ready
	player = Thunder._current_player
	player.completed = true
	await get_tree().create_timer(0.5, false).timeout
	var tw = create_tween()
	tw.tween_property(player, "modulate:a", 1.0, 1.0)
	await get_tree().create_timer(0.5, false).timeout
	_moving = true
	
	await get_tree().create_timer(2.5, false).timeout
	Audio.play_1d_sound(preload("res://sfx/IntroCastleCrush2.wav"))
	Thunder._current_camera.shock(2, Vector2(4, 4))
	tw = create_tween().set_parallel().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tw.tween_property(hugebitch_bottom, "position:y", 528, 1.9)
	tw.tween_property(hugebitch_top, "position:y", -48, 1.9)
	tw.chain().tween_interval(1.0)
	
	await tw.finished
	var aud1 = Audio.play_1d_sound(ZAMEK_LECI, false)
	Audio.play_1d_sound(BOWSER_DIED, false)
	var tw2 = create_tween().set_parallel().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tw2.tween_property(hugebitch_bottom, "position:y", 336, 0.8)
	tw2.tween_property(hugebitch_top, "position:y", 144, 0.8)
	
	await tw2.finished
	Audio.play_1d_sound(FALL, false)
	Audio.play_1d_sound(SND_LIGHTS_ON, false)
	Thunder._current_camera.shock(0.8, Vector2(4, 4))
	if is_instance_valid(aud1):
		aud1.queue_free()
	hugebitch_bottom.hide()
	hugebitch_top.hide()
	hugebitch.show()
	castle.hide()
	color_rect.color.a = 1.0
	tw2 = create_tween()
	tw2.tween_property(color_rect, "color:a", 0.0, 0.5).from(1.0)
	area_2d.player = player
	
	await get_tree().create_timer(2.5, false).timeout
	audio_stream_player_2d.play()
	moving_away = true
	area_2d.player = null


func _physics_process(delta: float) -> void:
	if _moving:
		player.speed.x = _player_speed
		_player_speed = move_toward(_player_speed, 325, delta * 250)
	
	if moving_away:
		hugebitch.position.x -= delta * 100
	if hugebitch.position.x < -272:
		_finished += delta
		audio_stream_player_2d.volume_linear = max(
			audio_stream_player_2d.volume_linear - delta, 0.0
		)
	if _finished > 2.0 && _finished < 999:
		_finished = 1000
		audio_stream_player_2d.playing = false
		Scenes.current_scene.end()


func run_while(callable: Callable, repeat_delay: float) -> void:
	if _finished: return
	callable.call()
	await get_tree().create_timer(repeat_delay, false, false, true).timeout
	run_while(callable, repeat_delay)
