extends Node

@export var path_to_level_1_4: String = "res://stages/world_2/level_2-1.tscn"

@onready var timer = $Timer

const GOOMBA = preload("res://engine/objects/enemies/goombas/goomba.tscn")


func _ready() -> void:
	timer.timeout.connect(_spawn_goomba)


func _spawn_goomba() -> void:
	if !is_instance_valid(Thunder._current_player) || Thunder._current_player.completed:
		return
	
	var instance = GOOMBA.instantiate()
	Thunder.view.cam_border()
	instance.global_position = Vector2(Thunder.view.border.position.x, Thunder.view.border.position.y)
	instance.global_position.x += 320 + 200 + randi_range(0, 200)
	instance.speed.y = 1000
	
	Scenes.current_scene.add_child(instance)
