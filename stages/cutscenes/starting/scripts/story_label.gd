extends Label


var speed = 6

func _ready() -> void:
	modulate.a = 0
	text = text % CharacterManager.get_character_display_name()

func _physics_process(delta: float) -> void:
	global_position.y -= speed * delta
	
	if global_position.y < 320 && global_position.y > 160:
		modulate.a = min(modulate.a + delta / 2, 1)
	elif global_position.y < 160:
		modulate.a = max(modulate.a - delta / 2, 0)
