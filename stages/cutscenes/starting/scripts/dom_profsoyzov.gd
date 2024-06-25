extends Node2D

@onready var node_2d = $Node2D
@onready var marker_2d = $"./Marker2D"
@onready var tanks = $"../Tanks"
@onready var init_pos = global_position
@onready var camera_2d = $"../Camera2D"

var c = 1

func _physics_process(delta: float) -> void:
	
	if marker_2d.global_position.x < camera_2d.global_position.x - 320: return
	
	if tanks.global_position.x < marker_2d.global_position.x + 320:
		global_position = Vector2(init_pos.x + randi_range(-2, 2), 2 * delta)
	
	if tanks.global_position.x < marker_2d.global_position.x + 128:
		node_2d.global_position.y += 30 * delta
		
		c -= delta * 20
		if c < 0 && node_2d.global_position.y < 256:
			c = 1
			var ex = preload("res://stages/cutscenes/starting/scripts/explosion_house.tscn").instantiate()
			ex.global_position = marker_2d.global_position
			Scenes.current_scene.add_child(ex)
