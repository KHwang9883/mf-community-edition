@tool
extends "res://engine/objects/warps/pipe_in.gd"

@export_file("*.tscn", "*.scn") var warp_to_remade_scene_tweak: String
var revamper
signal go
var dismissed: bool = false

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	if warp_to_remade_scene_tweak == "": return
	
	revamper = get_node_or_null("../RevampWarning/Control")
	if !revamper: return
	
	revamper.selected_new.connect(func() -> void:
		warp_to_scene = warp_to_remade_scene_tweak
		dismissed = true
	)
	revamper.selected_old.connect(func() -> void:
		dismissed = true
	)

func _warping_process(delta: float) -> void:
	if revamper && _duration >= _target && !dismissed:
		revamper.toggle()
	else:
		super(delta)
