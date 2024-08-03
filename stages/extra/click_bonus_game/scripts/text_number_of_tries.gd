extends HBoxContainer

var a: float = 1000
var b: float = 0

signal gameover

@export var try_count = 10:
	set(val):
		try_count = val
		_render_star_count()

@onready var value_1 = $HBoxContainer/Value1
@onready var value_2 = $HBoxContainer/Value2

func _ready() -> void:
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 1.5)


func _render_star_count() -> void:
	if try_count >= 10:
		value_1.texture.region.position.x = 24 * floor(try_count / 10.0)
	else:
		value_1.visible = false
	
	value_2.texture.region.position.x = 24 * (try_count % 10)


func _try_lost() -> void:
	if try_count == 0: return
	try_count -= 1
	if try_count == 0:
		Scenes.current_scene.gameover()
