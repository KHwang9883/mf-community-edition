extends Sprite2D

@onready var par = get_parent()

func _physics_process(delta: float) -> void:
	if flip_h && scale != Vector2.ONE * -1:
		scale = Vector2.ONE * -1
		reset_physics_interpolation()
