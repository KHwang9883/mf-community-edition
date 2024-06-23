extends Node2D

@onready var water = $"../Water"
var water_pos: float

func _ready():
	water_pos = water.position.y

func _physics_process(delta):
	water.position.y = move_toward(water.position.y, water_pos, delta * 50)

func set_water_height(by: float) -> void:
	Audio.play_1d_sound(preload("res://sfx/wodapodnosz.wav"))
	water_pos += by
	
