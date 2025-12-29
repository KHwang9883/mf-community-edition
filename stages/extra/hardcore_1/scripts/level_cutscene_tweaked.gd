extends LevelCutscene

@export_node_path("Area2D") var pipe_node: NodePath

func _ready() -> void:
	super()
	if Data.values.get("revamp_scene"):
		goto_path = Data.values.revamp_scene
		if pipe_node:
			var pipe = get_node(pipe_node)
			pipe.warp_to_scene = Data.values.revamp_scene
