extends PointLight2D

@onready var par = $'..'
var rand_pause: float

func _ready() -> void:
	assert(par is PointLight2D)
	rand_pause = par.rand_pause
	await get_tree().create_timer(rand_pause, false, false, false).timeout
	var tw3 = create_tween().set_loops().set_trans(Tween.TRANS_LINEAR)
	tw3.tween_interval(0.07)
	tw3.tween_property(self, "color:b", 0.3, 0.35)
	tw3.tween_interval(0.15)
	tw3.tween_property(self, "color:r", 0.5, 0.25)
	tw3.tween_interval(0.15)
	tw3.tween_property(self, "color:b", 1.0, 0.35)
	tw3.tween_interval(0.15)
	tw3.tween_property(self, "color:r", 1.0, 0.25)
	tw3.tween_interval(0.08)

func _process(delta: float) -> void:
	global_scale = Vector2.ONE
