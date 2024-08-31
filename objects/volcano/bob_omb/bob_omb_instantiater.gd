extends Node2D

@onready var bob_omb: GeneralMovementBody2D = $BobOmb

func _ready() -> void:
	Thunder.reorder_top(self)
	await get_tree().physics_frame
	bob_omb.speed.x = 350
	bob_omb.speed_to_dir()
	bob_omb.collision = false
	bob_omb.speed.y = -500
	bob_omb.global_rotation_degrees = 0
	global_rotation_degrees = 0
	var tw = create_tween().set_parallel()
	tw.tween_property(bob_omb, "speed:x", 50 * bob_omb.dir, 0.9)
	tw.tween_property(bob_omb, "global_rotation_degrees", 0, 0.01)
	await get_tree().create_timer(0.1, false, true).timeout
	bob_omb.collision = true
	bob_omb.gravity_scale = 0.5
	bob_omb.reparent(Scenes.current_scene)
	bob_omb.reset_physics_interpolation()
	await get_tree().create_timer(1, false, true).timeout
	queue_free()
