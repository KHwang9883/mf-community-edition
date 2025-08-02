extends "res://engine/objects/enemies/thwomp/thwomp.gd"

func _explosion() -> void:
	var exp: Node2D = explosion_effect.instantiate()
	exp.transform = transform
	exp.translate(left_explosion.position * scale)
	Scenes.current_scene.add_child(exp)
	var exp2: Node2D = explosion_effect.instantiate()
	exp2.transform = transform
	exp2.translate(right_explosion.position * scale)
	Scenes.current_scene.add_child(exp2)
