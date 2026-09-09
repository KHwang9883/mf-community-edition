extends Node2D

@onready var label: Label = $Label
var counter: float


func _process(delta: float) -> void:
	counter += delta
	label.text = "%.5f, %d" % [counter, Data.values.score]
	if Input.is_key_pressed(KEY_SPACE):
		Scenes.reload_current_scene()
		Data.values.score += 1
