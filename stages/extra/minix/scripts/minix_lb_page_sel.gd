extends MenuSelection

@export var change_page_by: int = -1

@onready var lb: Node2D = Scenes.current_scene.get_node(^"START/Leaderboard")

func _handle_select(mouse_input: bool = false) -> void:
	if !visible: return
	super(mouse_input)
	lb.page += change_page_by
	lb._load_records()
