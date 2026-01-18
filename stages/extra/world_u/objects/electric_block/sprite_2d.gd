extends Sprite2D

@export var range_amount: float = 0.1
@onready var init_modulate: float = self_modulate.v

func _physics_process(delta: float) -> void:
	self_modulate.v = init_modulate + randf_range(range_amount, -range_amount)
