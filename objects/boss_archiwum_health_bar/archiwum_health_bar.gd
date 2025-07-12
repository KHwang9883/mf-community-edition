extends TextureProgressBar

@export var from_archiwum: NodePath

func _physics_process(delta: float) -> void:
	var archiwum = get_node_or_null(from_archiwum)
	if archiwum:
		value = archiwum.lives
	else:
		value = 0

