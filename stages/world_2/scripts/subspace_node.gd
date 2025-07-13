extends Node

@onready var music_loader: Node = $"../../MusicLoader"
@onready var sub_space: Node2D = $"../../SubSpace"

func _ready() -> void:
	sub_space.process_mode = Node.PROCESS_MODE_DISABLED
	sub_space.hide()

func _on_cam_area_4_view_section_changed() -> void:
	if is_instance_valid(Thunder._current_hud):
		Thunder._disconnect(Thunder._current_hud.timer.timeout, Thunder._current_hud._on_timer_timeout)
	sub_space.process_mode = Node.PROCESS_MODE_INHERIT
	sub_space.show()
	Audio._music_tweens.clear()
	music_loader.index = 1
	if !1 in Audio._music_channels: return
	if !is_instance_valid(Audio._music_channels[1]): return
	var mus: AudioStreamPlayer = Audio._music_channels[1]
	mus.volume_db = -59.0
	Audio._music_tweens.clear()
	Audio.fade_music_1d_player(mus, 0.0, 6.0, Tween.TransitionType.TRANS_EXPO, false, Tween.EaseType.EASE_OUT)


func _on_cam_area_3_view_section_changed() -> void:
	if is_instance_valid(Thunder._current_hud):
		Thunder._connect(Thunder._current_hud.timer.timeout, Thunder._current_hud._on_timer_timeout)
