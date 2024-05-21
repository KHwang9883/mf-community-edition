extends Node2D

func disappear() -> void:
	for i in get_children():
		if i.has_method(&"disappear"):
			i.disappear()
