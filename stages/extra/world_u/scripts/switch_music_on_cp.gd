extends Node

@export var checkpoint_id: int
@export var music_index: int
@export_node_path("Node") var music_loader_ref: NodePath

@onready var music_loader = get_node_or_null(music_loader_ref)

func _ready() -> void:
	if Data.values.checkpoint == checkpoint_id:
		music_loader.index = music_index
