extends Node

@onready var hud: CanvasLayer = $".."
@onready var score: Label = hud.get_node("Control/MarioScore")

func _ready() -> void:
	Data.score_added.connect(_on_score_added, CONNECT_DEFERRED)
	_on_score_added.call_deferred()

func _on_score_added() -> void:
	if Data.values.score < 0:
		score.add_theme_color_override(&"font_color", Color(1.0, 0.314, 0.314))
	else:
		score.remove_theme_color_override(&"font_color")
