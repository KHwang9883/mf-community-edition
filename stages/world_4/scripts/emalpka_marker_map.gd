extends Node

@export var node_path: NodePath

func _ready() -> void:
	var tweak = SettingsManager.get_tweak("minigames_in_main_worlds", false)
	if !tweak:
		get_node(node_path).queue_free()
		return
