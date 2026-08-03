extends Node

@export_node_path("Node2D") var center_node: NodePath = ^".."
@export var creation: InstanceNode2D
@onready var par: Node2D = $".."

@warning_ignore("unused_private_class_variable")
@onready var _center: Node2D = get_node_or_null(center_node)

func _ready() -> void:
	par.splash_sequence_started.connect(spawn_body)


func spawn_body(at: Vector2) -> void:
	var vars: Dictionary = {
		enemy_attacked = self,
	}
	var node: Node2D = NodeCreator.prepare_ins_2d(creation, par) \
		.execute_instance_script(vars).create_2d().get_node()
	
	node.global_position = at + Vector2(32, 32)
	node.reset_physics_interpolation()
