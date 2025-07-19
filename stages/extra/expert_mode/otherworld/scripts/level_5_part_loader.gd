extends Node

const LEVEL_5_PART_1 = preload("res://stages/extra/expert_mode/otherworld/level_5_part1.tscn")
const LEVEL_5_PART_2 = preload("res://stages/extra/expert_mode/otherworld/level_5_part2.tscn")

var part_ref: Node2D

func _ready() -> void:
	if Data.values.checkpoint > 0:
		var part2 = LEVEL_5_PART_2.instantiate()
		Scenes.current_scene.add_child.call_deferred(part2)
	else:
		var part1 = LEVEL_5_PART_1.instantiate()
		Scenes.current_scene.add_child.call_deferred(part1)
		part_ref = part1


func _on_pipe_in_player_warped_to_pipe_out() -> void:
	var part2 = LEVEL_5_PART_2.instantiate()
	Scenes.current_scene.add_child(part2)
	if is_instance_valid(part_ref):
		part_ref.queue_free()
