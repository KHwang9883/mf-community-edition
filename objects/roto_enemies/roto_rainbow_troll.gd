@tool
extends "res://engine/objects/enemies/rotos/roto_red.gd"

func _ready() -> void:
	$Sprite.material.set_shader_parameter(&"mixing", true)

func _physics_process(delta: float) -> void:
	super(delta)
	if Engine.is_editor_hint(): return
	
	var player: Player = Thunder._current_player
	if !player: return
	if overlaps_body(player) && !player.is_starman():
		Thunder.add_score(-100)
