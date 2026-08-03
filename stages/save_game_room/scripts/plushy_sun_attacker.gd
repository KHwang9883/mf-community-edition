extends Node

var center_node: NodePath = ^"../.."
@warning_ignore("unused_private_class_variable")
@onready var _center = get_node_or_null(center_node)
var stomping_enabled: bool = false
@warning_ignore("unused_private_class_variable")
var _stomping_delayer: Variant = null

func got_killed(killer_type, special_tags: Array = [], trigger_enemy_failed_signal = false) -> Dictionary:
	if killer_type != "boomerang": return {}
	if _center:
		_center.body_entered()
	return {}

func got_stomped(by: Node2D, vel: Vector2, offset: Vector2 = Vector2(0, -16)) -> Dictionary:
	return {}
