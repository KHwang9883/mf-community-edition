extends PathFollow2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var speed: float = 0

func _physics_process(delta: float) -> void:
	progress += speed * delta
