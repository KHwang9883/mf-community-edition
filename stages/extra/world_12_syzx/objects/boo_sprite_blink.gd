extends Node

@export var for_circle: bool = false
@onready var phase: float = Thunder.rng.get_randf_range(0, 360)
@onready var par: Node2D = $".."
@onready var vision: VisibleOnScreenEnabler2D = par.get_node_or_null("Vision")

func _process(delta: float) -> void:
	phase = wrapf(phase + 2.0 * delta * 50, 0, 360)
	if vision && !vision.is_on_screen():
		return
	var mod_a: float = min(sin(deg_to_rad(phase)) + 1.067, 1.0)
	if for_circle:
		par.modulate.a = mod_a
	else:
		par.sprite.modulate.a = mod_a
	
