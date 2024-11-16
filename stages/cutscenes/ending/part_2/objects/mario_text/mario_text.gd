extends Node2D

@onready var label = $Label

func _ready() -> void:
	label.text = SettingsManager.settings.character + "!"
	
	var tw = create_tween().set_parallel()
	tw.tween_property(self, "global_position:y", global_position.y - 40, 0.2)
	tw.tween_property(self, "modulate:a", 0.0, 1)
	tw.finished.connect(queue_free)
