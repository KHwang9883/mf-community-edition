extends Node

func got_killed(killer_type, special_tags = {}, trigger_enemy_failed_signal = false) -> Dictionary:
	if killer_type != "boomerang": return {}
	$"../..".body_entered()
	return {}

func got_stomped(by: Node2D, vel: Vector2, offset: Vector2 = Vector2(0, -2)) -> Dictionary:
	return {}
