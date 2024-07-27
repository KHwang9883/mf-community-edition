extends Node

@export var enemies: Array[NodePath]

@onready var static_body_2d: StaticBody2D = $"../StaticBody2D"

var has_killed_all: bool

func _physics_process(delta: float) -> void:
	var has_enemies: bool = false
	for i in enemies:
		if is_instance_valid(get_node_or_null(i)):
			has_enemies = true
	
	if !has_enemies && !has_killed_all:
		has_killed_all = true
		await get_tree().create_timer(1.0, false).timeout
		Scenes.current_scene.finish(true)
		static_body_2d.queue_free()
