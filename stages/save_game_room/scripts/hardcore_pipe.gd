extends StaticBody2D

@export var secret: String = "passage to hardcore 1"

func _ready() -> void:
	hide()
	if SecretsManager.has_secret(secret):
		show()
		reset_physics_interpolation()
		return
	
	process_mode = Node.PROCESS_MODE_DISABLED
