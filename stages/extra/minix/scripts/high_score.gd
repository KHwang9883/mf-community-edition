extends Label

@export var minix_score_loader_path: NodePath
@export var starter_path: NodePath
@export var value: String

@onready var minix_score_loader: Node = get_node(minix_score_loader_path)
@onready var starter: Node2D = get_node(starter_path)

var has_loaded: bool = false

func _on_map_changed_to(map_id: int = 0) -> void:
	if !has_loaded: return
	var minix_name: String = "minix_" + starter.current_map.map_name
	print(minix_name)
	if minix_name in minix_score_loader.score_values:
		text = str(minix_score_loader.score_values[minix_name][value])
	else:
		text = "0"


func _on_minix_score_loader_score_loaded() -> void:
	has_loaded = true
	_on_map_changed_to.call_deferred()
#	(func():
#		text = str(minix_score_loader.score_values["minix_" + starter.current_map.map_name][value])
#	).call_deferred()

