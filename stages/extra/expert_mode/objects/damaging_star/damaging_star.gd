extends GeneralMovementBody2D

const BREAK = preload("res://engine/objects/bumping_blocks/_sounds/break.wav")
const EXPLOSION = preload("res://engine/objects/effects/explosion/explosion.tscn")

func _ready() -> void:
	var tw = create_tween().set_loops()
	tw.tween_property(sprite_node, "rotation_degrees", -360, 0.6)
	tw.tween_callback(func():
		sprite_node.rotation_degrees = 0.0
		sprite_node.reset_physics_interpolation()
	)
	get_tree().create_timer(6.0, false, true).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	if is_queued_for_deletion(): return
	super(delta)
	
	if is_on_floor() || is_on_wall() || is_zero_approx(speed.x):
		Audio.play_sound(BREAK, self, false)
		var expl = EXPLOSION.instantiate()
		expl.position = global_position
		Scenes.current_scene.add_child(expl)
		queue_free()
