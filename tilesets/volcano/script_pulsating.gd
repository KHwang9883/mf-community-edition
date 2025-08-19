extends CanvasItem

@export var divider: float = 3

var counter: float

func _process(delta: float) -> void:
	counter += delta
	modulate.v = 1.0 + (1 / divider) + (cos(counter * 3) / divider)
