extends Window

@onready var _prev_visible: bool = visible

func _physics_process(delta: float) -> void:
	if _prev_visible != visible && !visible:
		get_tree().paused = false
	_prev_visible = visible
