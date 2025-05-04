extends Label

@onready var player: Node2D = $"../Player"
func _physics_process(delta: float) -> void:
	
	if player.position.x < 113:
		show()
	else:
		hide()
