extends Node2D

@onready var pl: Player = Thunder._current_player
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var parallax_2d: Parallax2D = $Parallax2D
@onready var music_loader: Node = $"../MusicLoader"

@onready var init_brightness: float = canvas_modulate.color.v

var playing: bool
var bpm_index: int = -1
var bpm_old_index: int = -1
var rotation_arr: Array[float]
var timer: float

func _ready() -> void:
	rotation_arr.resize(parallax_2d.get_child_count())
	var children = parallax_2d.get_children()
	for i in parallax_2d.get_child_count():
		if !children[i] is PointLight2D: continue
		rotation_arr[i] = randf_range(2, 5)
		children[i].color.a = 0.0
		#var _tim = Timer.new()
		#_tim.autostart = true
		#children[i].add_child(_tim)
		#_tim.timeout.connect(random_move_light.bind(_tim, i))

func _physics_process(delta: float) -> void:
	if is_instance_valid(pl) && !playing && pl.warp == Player.Warp.NONE:
		playing = true
		music_loader.play_buffered()
	
	timer += delta
	for i: Node2D in parallax_2d.get_children():
		if !i is PointLight2D: continue
		i.rotation_degrees = sin(timer * rotation_arr[i.get_index()]) * 35
		i.color.a = move_toward(i.color.a, 0.0, delta * 2)
	
	if is_instance_valid(pl) && pl.completed:
		canvas_modulate.color.v = move_toward(canvas_modulate.color.v, 1.0, delta)
	else:
		canvas_modulate.color.v = move_toward(canvas_modulate.color.v, init_brightness, delta)
	
	var aud: AudioStreamPlayer = Audio._music_channels.get(1)
	if !is_instance_valid(aud) || !is_instance_valid(pl): return
	if !aud.playing || pl.completed: return

	var time = aud.get_playback_position() + AudioServer.get_time_since_last_mix()
	# Compensate for output latency.
	time -= AudioServer.get_output_latency()
	time = max(0, time)
	bpm_index = floori(-0.15 + time * 2.01667)
	bpm_index = max(0, bpm_index)
	if bpm_index != bpm_old_index:
		bpm_old_index = bpm_index
		#print("Time is: ", bpm_index)
		trigger_beat()

func trigger_beat() -> void:
	canvas_modulate.color.v = 1.0
	for i in parallax_2d.get_children():
		if !i is PointLight2D: continue
		i.color.a = 1.0
		i.color.s = 0.85
		i.color.h = randf_range(0, 1)
#
#func random_move_light(_tim: Timer, index: int) -> void:
	#_tim.start(randf_range(0.4, 3.0))
	#
	#rotation_arr[index] += randf_range(-1.0, 1.0)
	#rotation_arr[index] = clampf(rotation_arr[index], 2.0, 6.0)
