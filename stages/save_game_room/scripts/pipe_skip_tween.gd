extends Sprite2D

func _ready() -> void:
	hide()


func set_pos() -> void:
	visible = true
	position.y = 32


func go_away() -> void:
	var tw = create_tween()
	tw.tween_property(self, "position:y", -96, 1.0)
	tw.tween_callback(hide)
