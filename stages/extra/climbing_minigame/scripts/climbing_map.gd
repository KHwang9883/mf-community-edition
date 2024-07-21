extends Node2D
class_name ClimbingMap

@export var map_name: String
@export var life_count: int = 1
@export var start_again_on_replay: bool = true
@export var timers_node_path: NodePath = ^"Timers"
@export var moving_group_node_path: NodePath = ^"MovingGroup"
@export_group("Camera Settings")
@export var cam: Node

@onready var timers: Node = get_node(timers_node_path)
@onready var moving_group: Node2D = get_node(moving_group_node_path)

signal game_started

func _ready() -> void:
	while !is_instance_valid(Scenes.custom_scenes.minix_node):
		await get_tree().physics_frame
	if is_instance_valid(Scenes.custom_scenes.minix_node):
		Scenes.custom_scenes.minix_node.game_started.connect(_on_game_started)


func _on_game_started() -> void:
	var starter = Scenes.custom_scenes.minix_node
	if starter.current_map != self:
		return
	game_started.emit()
	
	Data.reset_all_values()
