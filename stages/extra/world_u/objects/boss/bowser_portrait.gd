extends Sprite2D

const GRAVITY: float = 2500.0

var follow: Node2D
var velocity: Vector2
var activated: bool

func _physics_process(delta: float) -> void:
	if !follow && !activated: return
	if activated:
		velocity += Vector2.DOWN.rotated(global_rotation) * GRAVITY * 0.15 * delta
		position += velocity * delta
		return
	
	if follow.move:
		activated = true
