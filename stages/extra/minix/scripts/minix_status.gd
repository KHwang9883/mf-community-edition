extends AnimatedSprite2D

const scoring_sound = preload("res://stages/extra/minix/status/minix_coin_time.wav")
const status_sounds: Array[AudioStream] = [
	preload("res://stages/extra/minix/status/status1.wav"),
	preload("res://stages/extra/minix/status/status2.wav"),
	preload("res://stages/extra/minix/status/status3.wav"),
	preload("res://stages/extra/minix/status/status4.wav"),
	preload("res://stages/extra/minix/status/status5.wav"),
	preload("res://stages/extra/minix/status/status_final.wav")
]

var tw: Tween = null
var _offset: float = 0.0

var last_status: int = 0
var godlike_count: int = 0
var godlike_bool: bool

func status(combo: int) -> void:
	if combo <= 1: return
	
	match combo:
		2, 3, 4, 5, 6:
			if last_status <= combo:
				frame = combo - 2
				_offset = 6 + (2 * combo)
				last_status = combo
				_set_modulation()
	match combo:
		2:
			Audio.play_music(status_sounds[0], 50)
		3:
			Audio.stop_music_channel(50, false)
			Audio.play_music(status_sounds[1], 51)
		4:
			Audio.stop_music_channel(50, false)
			Audio.stop_music_channel(51, false)
			Audio.play_music(status_sounds[2], 52)
		5:
			Audio.stop_music_channel(50, false)
			Audio.stop_music_channel(51, false)
			Audio.stop_music_channel(52, false)
			Audio.play_music(status_sounds[3], 53)
		6:
			Audio.stop_music_channel(50, false)
			Audio.stop_music_channel(51, false)
			Audio.stop_music_channel(52, false)
			Audio.stop_music_channel(53, false)
			Audio.play_music(status_sounds[4], 54)
		10:
			frame = 5
			_offset = 20
			last_status = 10
			godlike_count += 40000
			if godlike_bool == false:
				_time_countdown_sound_loop()
			_init_godlike()
			_set_modulation()
			
			Audio.stop_music_channel(50, false)
			Audio.stop_music_channel(51, false)
			Audio.stop_music_channel(52, false)
			Audio.stop_music_channel(53, false)
			Audio.stop_music_channel(54, false)
			Audio.play_music(status_sounds[5], 55)


func _physics_process(delta: float) -> void:
	if _offset > 0.0:
		offset = Vector2(randf_range(-_offset, _offset), randf_range(-_offset, _offset)) / 2.0
		_offset -= 50 * delta


func _set_modulation() -> void:
	self_modulate.a = 1
	if tw && tw.is_valid():
		tw.stop()
	tw = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tw.tween_interval(2.0)
	tw.tween_property(self, "self_modulate:a", 0.0, 2.4)
	tw.tween_callback(func():
		last_status = 0
	)


func _init_godlike() -> void:
	print(godlike_count)
	if godlike_bool: return
	godlike_bool = true
	
	while godlike_count > 0:
		await get_tree().create_timer(0.02, false).timeout
		Data.values.score += 100
		godlike_count -= 100
		if godlike_count <= 100:
			godlike_bool = false


func _time_countdown_sound_loop() -> void:
	if godlike_count > 0:
		Audio.play_1d_sound(scoring_sound)
		await get_tree().create_timer(0.09, false, false, true).timeout
		_time_countdown_sound_loop()
