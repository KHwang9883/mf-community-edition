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


func _physics_process(delta: float) -> void:
	if !is_instance_valid(player): return
	
	if player.reached && player.current_marker == self && !activated:
		activated = true
		SecretsManager.set_secret("treasure level found", true, true, false)
		Audio.play_1d_sound(preload("res://stages/world_6/scripts/newpath.ogg"))
