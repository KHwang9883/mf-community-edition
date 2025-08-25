extends Node

func _on_area_entered(area: Area2D) -> void:
	if !area.has_node(^"EnemyAttacked"): return
	var enemy_att = area.get_node(^"EnemyAttacked")
	if enemy_att.killing_immune.has(&"lava"):
		if enemy_att.killing_immune.lava == false:
			enemy_att.got_killed(&"lava", [&"no_score"])
