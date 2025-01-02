extends "res://stages/world_1/scripts/bowser_fake_reveal.gd"

@export var creation_2: InstanceNode2D
var first_launched: bool = false

func spawn_body(at: Vector2) -> void:
	if !first_launched:
		super(at)
		first_launched = true
	else:
		spawn_body_2(at)


func spawn_body_2(at: Vector2) -> void:
	var vars: Dictionary = {
		enemy_attacked = self,
	}
	var node: Node2D = NodeCreator.prepare_ins_2d(creation_2, par) \
		.execute_instance_script(vars).create_2d().get_node()
	
	node.global_position = at + Vector2(32, 32)
	node.reset_physics_interpolation()
