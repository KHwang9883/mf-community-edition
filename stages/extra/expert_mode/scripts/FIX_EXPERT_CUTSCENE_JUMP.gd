extends Node

@export var goto: String

func _physics_process(delta: float) -> void:
	if !is_instance_valid(Scenes.current_scene): return
	Scenes.current_scene.goto_path = Scenes.get_scene_path(goto)
