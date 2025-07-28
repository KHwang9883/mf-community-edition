extends Node

var locked: bool = false

func _ready() -> void:
	if Data.values.checkpoint == -1:
		locked = false

func _on_cam_area_2_view_section_changed() -> void:
	if locked: return
	locked = true
	
	
