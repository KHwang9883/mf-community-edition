extends ByNodeScript

func _ready() -> void:
	if node is Powerup:
		node.appear_distance = 0
