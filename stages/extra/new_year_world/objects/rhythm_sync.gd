extends PointLight2D
var old_row: int = -1

#func _ready() -> void:
#	Scenes.current_scene.get_node("MusicLoader").play_buffered()

var odd_frame: bool
func _physics_process(delta: float) -> void:
	odd_frame = !odd_frame # No delta because physics_process runs at fixed framerate
	
	energy = move_toward(energy, 0.1, delta * 4)
	
	if odd_frame: return
	if !Audio._music_channels.has(1): return
	if !is_instance_valid(Audio._music_channels[1]) || !Audio._music_channels[1].playing: return
	if !Audio._music_channels[1].stream: return
	var playback = Audio._music_channels[1].get_stream_playback()
	#var pattern: int = playback.get_current_pattern()
	if playback is AudioStreamPlaybackMPT:
		var row: int = playback.get_current_row()
		if row == old_row: return
		old_row = row
		if row % 8 == 0:
			_syncevent()

func _syncevent():
	energy = 2
	color.s = 0.85
	color.h = randf_range(0, 1)
