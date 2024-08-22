@tool
extends MapPlayerMarker

var activated: bool

func _ready() -> void:
	_ready_mixin()
	super()


func _ready_mixin() -> void:
	if Engine.is_editor_hint(): return
	
	if !Data.values.get("treasure"):
		level = ""
		level_override_save = ""
	
	var player = Scenes.current_scene.get_node_or_null(Scenes.current_scene.player)
	
	if !is_instance_valid(player): return
	
	if player.reached && player.current_marker == self && !activated:
		activated = true
		Audio.play_1d_sound(preload("res://stages/world_6/scripts/newpath.ogg"))
