extends Node

@onready var timer = $Timer

const GOOMBA = preload("res://engine/objects/enemies/goombas/goomba.tscn")


func _ready() -> void:
	timer.timeout.connect(_spawn_goomba)


func _spawn_goomba() -> void:
	if !is_instance_valid(Thunder._current_player) || Thunder._current_player.completed:
		return
	
	var new_position: float = Thunder.view.border.position.x
	await get_tree().create_timer(0.3, false).timeout
	if !is_instance_valid(Thunder._current_player) || Thunder._current_player.completed:
		return
	var instance = GOOMBA.instantiate()
	Thunder.view.cam_border()
	instance.position = Vector2(new_position, Thunder.view.border.position.y)
	instance.position.x += 320 + 200 + randi_range(0, 200)
	instance.reset_physics_interpolation()
	instance.speed.y = 1000
	instance.max_falling_speed = 625
	
	Scenes.current_scene.add_child(instance)
