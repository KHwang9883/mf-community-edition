extends Node

func make_leaving() -> void:
	for i in get_tree().get_nodes_in_group(&"big_bertha_follow"):
		i.set_as_leaving()
