extends Node
class_name Util

static func get_packed_scene_texture(scene: PackedScene, prefer_anim: String = "") -> Texture2D:
	var state = scene.get_state()
	var specific_node = null
	var specific_index: int = -1
	var specific_anim: String
	for i in state.get_node_count():
		if specific_node != null && specific_index == -1:
			#prints(specific_node, str(state.get_node_path(i, false)).right(-2))
			if specific_node == str(state.get_node_path(i, false)).right(-2):
				specific_index = i
		if specific_index != -1 && i != specific_index:
			continue
		for j in state.get_node_property_count(i):
			var propname = state.get_node_property_name(i, j)
			
			if specific_node == null && propname == "sprite":
				specific_node = str(state.get_node_property_value(i, j))
			if propname == "animation":
				specific_anim = state.get_node_property_value(i, j)
				continue
			if propname in ["sprite_frames", "texture"]:
				var prop = state.get_node_property_value(i, j)
				if is_instance_of(prop, Texture2D):
					return prop
				elif is_instance_of(prop, SpriteFrames):
					var anims: PackedStringArray = prop.get_animation_names()
					var anim := anims[0] if !specific_anim else specific_anim
					if prefer_anim && anims.has(prefer_anim):
						anim = prefer_anim
					return prop.get_frame_texture(anim, 0)
	
	return null
