extends Node2D

const STUPIDY_STAGE = preload("res://stages/extra/world_of_stupidity/chmurka_debil/stupidy STAGE.wav")

func _ready() -> void:
	hide()

func _on_body_entered(body: Node2D) -> void:
	if body is Player && !visible:
		show()
		Audio.play_1d_sound(STUPIDY_STAGE)
