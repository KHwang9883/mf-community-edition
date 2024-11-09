extends "res://stages/extra/world_of_stupidity/chmurka_debil/stupidity_cloud.gd"

@export var offset_by: float

func _ready() -> void:
	super()
	if CharacterManager.get_character_name() == "Luigi":
		position.x += offset_by
