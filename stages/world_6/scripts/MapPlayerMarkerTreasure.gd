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
		if Thunder.autosplitter.can_split_on("achievement_mfce") && !SecretsManager.has_secret("treasure level found"):
			Thunder.autosplitter.split()
		SecretsManager.set_secret("treasure level found", true, true, true)
		Audio.play_1d_sound(preload("res://stages/world_6/scripts/newpath.ogg"))
