extends Label

@onready var selector = $"../Selector"

func _physics_process(_delta: float) -> void:
	var lb = Scenes.current_scene.get_node("START/Leaderboard")
	
	text = "loading..." if lb.is_loading else "no results...\nbecome the first one!"
	selector.visible = lb.has_results
