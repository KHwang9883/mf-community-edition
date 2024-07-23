extends Label

@onready var selector = $"../Selector"

func _physics_process(_delta: float) -> void:
	var lb = Scenes.current_scene.get_node("START/Leaderboard")
	
	text = "loading..." if lb.is_loading else "no results...\nbecome the first one!"
	if lb.old:
		text = "this game has been discontinued.\nplease download\nmario forever: community edition\nto use the leaderboard system!"
	selector.visible = lb.has_results
