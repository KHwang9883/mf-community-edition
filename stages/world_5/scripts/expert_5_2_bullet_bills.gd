extends Node2D

@onready var node_2d: Node2D = $Node2D

func _physics_process(delta: float) -> void:
	var player = Thunder._current_player
	if !is_instance_valid(player): return
	
	node_2d.process_mode = PROCESS_MODE_INHERIT if player.global_position.y > 640 else PROCESS_MODE_DISABLED
