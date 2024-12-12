extends Label

@export var call_by_pronouns: bool = true

var speed = 6

func _ready() -> void:
	modulate.a = 0
	if call_by_pronouns:
		text = text.format([CharacterManager.get_character_story_text(0)], "%s")
	else:
		text = text.format([CharacterManager.get_character_story_text(2), CharacterManager.get_character_display_name()], "%s")

func _physics_process(delta: float) -> void:
	global_position.y -= speed * delta
	
	if global_position.y < 320 && global_position.y > 160:
		modulate.a = min(modulate.a + delta / 2, 1)
	elif global_position.y < 160:
		modulate.a = max(modulate.a - delta / 2, 0)
