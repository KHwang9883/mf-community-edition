extends Node2D

var is_inside: bool
var is_playing: bool
var yapper_2_talks: bool

@export var yapper_1_lines: Array[AudioStream] = [
	preload("res://sfx/house_of_clones/AAA_gadacz1.wav"), preload("res://sfx/house_of_clones/AAA_gadacz2.wav"), preload("res://sfx/house_of_clones/AAA_gadacz3.wav"), preload("res://sfx/house_of_clones/AAA_gadacz4.wav"), preload("res://sfx/house_of_clones/AAA_gadacz5.wav"),
]
@export var yapper_2_lines: Array[AudioStream] = [
	preload("res://sfx/house_of_clones/AAA_gadacz1b.wav"), preload("res://sfx/house_of_clones/AAA_gadacz2b.wav"), preload("res://sfx/house_of_clones/AAA_gadacz3b.wav"), preload("res://sfx/house_of_clones/AAA_gadacz4b.wav"), preload("res://sfx/house_of_clones/AAA_gadacz5b.wav"),
]
@onready var yapper_1: AnimatedSprite2D = $Yapper
@onready var yapper_2: AnimatedSprite2D = $Yapper2
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_area_2d_player_enter() -> void:
	is_inside = true


func _on_area_2d_player_exit() -> void:
	is_inside = false


func _physics_process(delta: float) -> void:
	if !is_inside || is_playing: return
	if yapper_2_talks:
		audio_player.stream = yapper_2_lines[randi_range(0, yapper_2_lines.size() - 1)]
		yapper_2.play("talking")
	else:
		audio_player.stream = yapper_1_lines[randi_range(0, yapper_1_lines.size() - 1)]
		yapper_1.play("talking")
	audio_player.play()
	is_playing = true


func _on_audio_stream_player_2d_finished() -> void:
	yapper_1.animation = "default"
	yapper_2.animation = "default"
	await get_tree().create_timer(0.5, false, false).timeout
	yapper_2_talks = !yapper_2_talks
	is_playing = false
