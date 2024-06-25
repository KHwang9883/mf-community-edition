extends ColorRect

var out: bool = false

func _physics_process(delta: float) -> void:
	if out:
		modulate.a -= 4 * delta
