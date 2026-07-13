extends Node2D

var is_inside: bool
var is_playing: bool
var yapper_2_talks: bool

@export var yapper_lines: Array[AudioStream] = []
@onready var yapper: AnimatedSprite2D = $YapperNews
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
var delay: float
var last_one: int = -1

func _on_area_2d_player_enter() -> void:
	is_inside = true


func _on_area_2d_player_exit() -> void:
	is_inside = false


func _physics_process(delta: float) -> void:
	if !is_inside || is_playing: return
	delay += delta * 50
	if delay > 20:
		var rand_number: int = randi_range(0, yapper_lines.size() - 1)
		if last_one == rand_number && last_one != 3:
			rand_number = randi_range(0, yapper_lines.size() - 1)
		audio_player.stream = yapper_lines[rand_number]
		last_one = rand_number
		yapper.play(&"talking" if rand_number != 3 else &"default")
		audio_player.play()
		is_playing = true
		delay = 0


func _on_audio_stream_player_2d_finished() -> void:
	yapper.animation = &'default'
	is_playing = false
