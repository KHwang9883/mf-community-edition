extends Node

const BUBBLES = preload("res://objects/human_lab/container/sfx/bubbles.ogg")
@onready var area: Area2D = $".."
var delay: float = 2

func _physics_process(delta: float) -> void:
	if area.player != null:
		delay += delta
	
	if delay > 2.0:
		Audio.play_1d_sound(BUBBLES)
		delay = 0
	
