extends Node2D

@export var sounds: Array[AudioStream] = [
	preload("res://sfx/house_of_clones/AAA_kibord1.wav"), preload("res://sfx/house_of_clones/AAA_kibord2.wav"), preload("res://sfx/house_of_clones/AAA_kibord3.wav"), preload("res://sfx/house_of_clones/AAA_kibord4.wav"),
]
@export var random_pick: int = 10
@export var delay_sec: float = 0.1

var is_inside: bool
var delay: bool

func _ready() -> void:
	$Area2D.player_enter.connect(_on_player_entered)
	$Area2D.player_exit.connect(_on_player_exited)


func _physics_process(delta: float) -> void:
	if !is_inside || delay: return
	var random_pick: int = randi_range(0, random_pick - 1)
	if random_pick < sounds.size():
		Audio.play_1d_sound(sounds[random_pick])
	
	delay = true
	await get_tree().create_timer(delay_sec, false, false, true).timeout
	delay = false


func _on_player_entered() -> void:
	is_inside = true


func _on_player_exited() -> void:
	is_inside = false
