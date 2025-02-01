@tool
extends "res://engine/objects/warps/pipe_in.gd"

@export_file("*.tscn", "*.scn") var warp_to_remade_scene_tweak: String
var revamper
signal go

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	if warp_to_remade_scene_tweak == "": return
	
	revamper = get_node_or_null("../RevampWarning/Control")
	if !revamper: return
	
	revamper.selected_new.connect(func() -> void:
		warp_to_scene = warp_to_remade_scene_tweak
		go.emit()
	)
	revamper.selected_old.connect(func() -> void:
		go.emit()
	)

func pass_warp() -> void:
	if revamper:
		revamper.toggle()
		await go
	Audio.stop_all_musics()
	Audio.stop_all_sounds()
	super()
