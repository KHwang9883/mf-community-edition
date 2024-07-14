extends MenuSelection

@onready var node_2d: Node2D = $"../.."
@onready var mario: CharacterBody2D = $"../../../../Mario"

signal game_started

func _ready() -> void:
	mario.completed = true

func _handle_select() -> void:
	super()
	get_parent().focused = false
	Audio.stop_music_channel(0, true)
	node_2d.music()
	var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(node_2d, "modulate:a", 0.0, 0.5)
	
	mario.process_mode = Node.PROCESS_MODE_INHERIT
	mario.completed = false
	game_started.emit()
