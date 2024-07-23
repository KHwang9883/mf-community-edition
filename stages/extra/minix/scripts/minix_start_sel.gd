extends MenuSelection

@onready var node_2d: Node2D = $"../.."
@onready var control = $"../../../Leaderboard/SubViewportContainer/SubViewport/Control/CanvasLayer/Title"

func _handle_select() -> void:
	super()
	get_parent().focused = false
	node_2d.start_game()
	control.map_id = node_2d.map_id + 1
	control._update_map()
