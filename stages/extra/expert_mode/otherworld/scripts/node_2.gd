extends Marker2D

const BUZZLE_BEETLE_SHELL = preload("res://engine/objects/enemies/buzzle_bettle/buzzle_beetle_shell.tscn")
@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(_on_timeout)


func _on_timeout() -> void:
	var node: Node = get_tree().get_first_node_in_group(&"buzzy_beetle_regen")
	if is_instance_valid(node): return
	
	var buzzy = BUZZLE_BEETLE_SHELL.instantiate()
	buzzy.position = position
	add_sibling(buzzy)
	buzzy.add_to_group(&"buzzy_beetle_regen")
