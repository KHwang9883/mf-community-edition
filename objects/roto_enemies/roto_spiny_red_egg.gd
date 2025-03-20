extends "res://engine/objects/enemies/spinies/spiny_egg.gd"

func _create_spiny() -> void:
	NodeCreator.prepare_ins_2d(spiny_creation, self).create_2d().call_method(func(node):
		var spr = node.get_node(node.sprite)
		if "free_offscreen" in spr:
			spr.free_offscreen = free_offscreen
		if spr.sprite_frames.has_animation(&"appear"):
			spr.play(&"appear")
		
		var roto = $RotoCenter
		roto.reparent(node, true)
		roto.reset_physics_interpolation()
	)
	queue_free()
