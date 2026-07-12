extends CanvasLayer

@onready var node_2d: Node2D = $Node2D
@onready var label: Label = $Node2D/Node2D/Label

func _ready() -> void:
	hide()
	node_2d.modulate.a = 0
	if KevinGlobal.activated:
		Thunder._current_player.died.connect(on_player_died, CONNECT_ONE_SHOT)

func on_player_died():
	await get_tree().create_timer(0.5, false, false, true).timeout
	show()
	label.text %= Data.values.score
	var tw = node_2d.create_tween()
	tw.tween_property(node_2d, "modulate:a", 1.0, 2.0)
