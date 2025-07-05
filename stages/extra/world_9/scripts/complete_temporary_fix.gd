extends Node

@export var actually_real_goto: String 

func _ready() -> void:
	await get_tree().create_timer(0.3, true, false, true).timeout
	if !is_inside_tree(): return
	get_parent().goto_scene = actually_real_goto
