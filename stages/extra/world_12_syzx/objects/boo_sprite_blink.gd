extends Node

@onready var phase: float = Thunder.rng.get_randf_range(0, 360)
@onready var par: Node2D = $".."
@onready var vision: VisibleOnScreenEnabler2D = par.get_node("Vision")

func _process(delta: float) -> void:
	phase = wrapf(phase + 2.0 * delta * 50, 0, 360)
	if !vision.is_on_screen():
		return
	par.sprite.modulate.a = min(sin(deg_to_rad(phase)) + 1.067, 1.0)
	
