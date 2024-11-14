extends Node

@export var as_cutscene: bool = true
@export var z_ind: int = -5

func _ready() -> void:
	if KevinGlobal.activated:
		var kev = KevinGlobal.KEVIN_SCENE.instantiate()
		kev.cutscene = as_cutscene
		kev.position = Vector2(-100, -100)
		Scenes.current_scene.add_child.call_deferred(kev)
		kev.z_index = z_ind
