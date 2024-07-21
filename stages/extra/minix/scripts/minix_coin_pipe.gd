extends Node2D

@onready var pipe_timer: Timer = $PipeTimer

const COIN_FROM_PIPE = preload("res://stages/extra/minix/objects/coin_from_pipe.tscn")


func _ready() -> void:
	while !is_instance_valid(Scenes.custom_scenes.minix_node):
		await get_tree().physics_frame
	if is_instance_valid(Scenes.custom_scenes.minix_node):
		Scenes.custom_scenes.minix_node.game_started.connect(_on_game_started)


func _on_game_started() -> void:
	pipe_timer.start()


func _on_pipe_timeout() -> void:
	position = Vector2(randi_range(80, 560), 528)
	Audio.play_sound(preload("res://engine/objects/bumping_blocks/_sounds/appear.wav"), self, false)
	
	var tw = create_tween()
	tw.tween_property(self, "position:y", 432, 1.5)
	tw.tween_callback(_pipe_burst)


func _pipe_burst() -> void:
	var i: int = 20
	while i > 0:
		await get_tree().create_timer(0.05, false).timeout
		i -= 1
		
		var coin_inst = COIN_FROM_PIPE.instantiate()
		coin_inst.position = position
		coin_inst.speed = Vector2(randf_range(-250, 250), randf_range(-500, -350))
		Scenes.current_scene.add_child(coin_inst)
		var tw = coin_inst.create_tween()
		tw.tween_property(coin_inst, "scale", Vector2.ONE, 0.2)
		tw.tween_callback(coin_inst.get_node("Area2D").set_collision_mask_value.bind(1, true))
		
		if i == 0:
			create_tween().tween_property(self, "position:y", 432+96, 1.5)
