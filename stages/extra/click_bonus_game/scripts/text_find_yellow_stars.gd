extends HBoxContainer

@onready var value_1 = $HBoxContainer/Value1
@onready var value_2 = $HBoxContainer/Value2

signal complete

var a: float = 1000
var b: float = 0

var star_count = 100:
	set(val):
		star_count = val
		_render_star_count()

func _ready() -> void:
	star_count = len(get_tree().get_nodes_in_group("bonus_star"))

func _process(delta: float) -> void:
	if a > 0:
		a -= delta * 300
		b += delta * 5
	position.x = a * sin(b)

func _render_star_count() -> void:
	if star_count >= 10:
		value_1.texture.region.position.x = 24 * floor(star_count / 10)
	else:
		value_1.visible = false
	
	value_2.texture.region.position.x = 24 * (star_count % 10)

func _star_collected() -> void:
	star_count -= 1
	if star_count == 0:
		complete.emit()
