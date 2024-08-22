@tool
extends MapPlayerMarker

func _ready() -> void:
	_ready_mixin()
	super()


func _ready_mixin() -> void:
	if Engine.is_editor_hint(): return
	
	if !Data.values.get("treasure"):
		level = ""
		level_override_save = ""
