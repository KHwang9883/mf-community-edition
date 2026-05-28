extends "res://engine/objects/enemies/thwomp/scripts/thwomp.gd"

func _explosion() -> void:
	var exp1: Node2D = explosion_effect.instantiate()
	exp1.transform = transform
	exp1.translate(left_explosion.position * scale)
	Scenes.current_scene.add_child(exp1)
	var exp2: Node2D = explosion_effect.instantiate()
	exp2.transform = transform
	exp2.translate(right_explosion.position * scale)
	Scenes.current_scene.add_child(exp2)
