extends Area2D

func _ready() -> void:
	if ProfileManager.current_profile.has_completed(&"res://stages/extra/lost_map/lost_map_5.tscn"):
		area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if !is_instance_valid(area.get_parent()): return
	#var par = area.get_parent()
	#if !par.is_in_group(&"map_dot"): return
	#par.visible = true
