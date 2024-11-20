extends Node

@export var teleport_by: float = 640


func entered() -> void:
	var player = Thunder._current_player
	if !player: return
	player.position.x -= teleport_by
	player.reset_physics_interpolation()
	for i in Scenes.current_scene.get_children():
		if i is Projectile:
			i.position.x -= teleport_by
			i.reset_physics_interpolation()
	for i in get_tree().get_nodes_in_group(&"Trail"):
		i.position.x -= teleport_by
		i.reset_physics_interpolation()
	
	Audio.play_1d_sound(preload("res://sfx/incorrect.wav"))
	
	var camera: PlayerCamera2D = Thunder._current_camera
	camera.teleport(false, true)
