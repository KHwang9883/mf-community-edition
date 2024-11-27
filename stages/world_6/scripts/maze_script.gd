extends Node

@export var teleport_by: float = 640


func entered() -> void:
	var player = Thunder._current_player
	if !player: return
	var camera: PlayerCamera2D = Thunder._current_camera
	camera.stop_blocking_edges = true
	camera.set(&"ignore_retro_scroll", true)
	var old_xscroll = camera._xscroll
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
	
	camera.teleport(false, true)
	camera._xscroll = old_xscroll
	camera.reset_physics_interpolation()
	camera.stop_blocking_edges = false
	camera.set(&"ignore_retro_scroll", false)
	
