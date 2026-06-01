extends Sprite2D

var follow: Node2D

func _physics_process(delta: float) -> void:
	if !follow: return
	
	if follow.move:
		position += follow.velocity * delta
