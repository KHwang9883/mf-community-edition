extends ByNodeScript

func _ready() -> void:
	await node.get_tree().physics_frame
	node.index = randi_range(0, len(node.current_music) - 1)
	node.play_buffered()
