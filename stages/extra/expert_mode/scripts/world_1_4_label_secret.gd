extends Node

@onready var label: Label = $".."

func activate() -> void:
	var tw = create_tween()
	tw.tween_property(label, "visible_characters", 28, 0.25).from(40)
	tw.tween_interval(0.15)
	tw.tween_callback(label.set_text.bind("YOU HAVE FOUND A SECRET WAY TO THIS ROOM!!!"))
	tw.tween_property(label, "visible_ratio", 1.0, 0.3)
