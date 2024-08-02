extends Area2D

func _input(event: InputEvent) -> void:
	return
	print(event)


func _on_mouse_entered() -> void:
	print("AAA")


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print(event)
