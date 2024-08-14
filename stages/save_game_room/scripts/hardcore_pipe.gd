extends StaticBody2D

@export var secret: String = "passage to hardcore 1"

func _ready() -> void:
	hide()
	if SecretsManager.has_secret(secret):
		show()
		return
	
	process_mode = Node.PROCESS_MODE_DISABLED
