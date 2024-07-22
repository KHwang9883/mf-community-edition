extends Node

@onready var status: AnimatedSprite2D = $"../CanvasLayer/Status"
@onready var starter: Node2D = $"../START/Node2D"
@onready var life_nodes: Array[Node2D] = [
	$"../CanvasLayer/Node2D",
	$"../CanvasLayer/Node2D2",
	$"../CanvasLayer/Node2D3"
]

func _ready() -> void:
	print("Script ready")
	Data.reset_all_values()


func _on_game_started() -> void:
	(func():
		process_mode = Node.PROCESS_MODE_INHERIT
		
		for i in len(life_nodes):
			var life_count: int = starter.current_map.life_count
			if life_count <= i:
				life_nodes[i].visible = false
	).call_deferred()


func _on_mario_damaged_to(lives: int) -> void:
	life_nodes[lives].get_node("AnimatedSprite2D").fade_out()
