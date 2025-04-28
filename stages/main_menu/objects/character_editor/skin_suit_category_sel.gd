extends "res://stages/main_menu/scripts/tweak_category_sel.gd"

const BOOL_SUIT_TWEAK_SELECTION = preload("res://stages/main_menu/objects/character_editor/bool_suit_tweak_selection.tscn")
const FLOAT_SUIT_TWEAK_SELECTION = preload("res://stages/main_menu/objects/character_editor/float_suit_tweak_selection.tscn")

@export var powerup_name: String

@onready var h_separator_spawn: HSeparator = $"../../SkinSuitSettings/HSeparatorSpawnTweaks"

func _handle_select(mouse_input: bool = false) -> void:
	if SkinsManager.current_skin && SkinsManager.custom_textures.has(SkinsManager.current_skin):
		get_tree().call_group(&"_skin_suit_tweak", &"queue_free")
		var _char = CharacterManager.get_character_name()
		if !CharacterManager.suit_tweaks.has(_char):
			print("Warning: No suit tweaks for char: ", _char)
		elif CharacterManager.suit_tweaks[_char].has(powerup_name):
			for i in CharacterManager.suit_tweaks[_char][powerup_name]:
				if CharacterManager.suit_tweaks[_char][powerup_name][i] is bool:
					var _bool_tweak = BOOL_SUIT_TWEAK_SELECTION.instantiate()
					_bool_tweak.get_node("Label").text = i.replacen("_", " ")
					_bool_tweak.tweak_name = i
					_bool_tweak.is_toggled = CharacterManager.suit_tweaks[_char][powerup_name][i]
					move_to.add_child(_bool_tweak)
					Thunder.reorder_on_top_of(_bool_tweak, h_separator_spawn)
				elif CharacterManager.suit_tweaks[_char][powerup_name][i] is float:
					var _float_tweak = FLOAT_SUIT_TWEAK_SELECTION.instantiate()
					_float_tweak.get_node("Label").text = i.replacen("_", " ")
					_float_tweak.get_node("Label2").text = str(CharacterManager.suit_tweaks[_char][powerup_name][i])
					_float_tweak.tweak_name = i
					move_to.add_child(_float_tweak)
					Thunder.reorder_on_top_of(_float_tweak, h_separator_spawn)
				elif CharacterManager.suit_tweaks[_char][powerup_name][i] is int:
					var _float_tweak = FLOAT_SUIT_TWEAK_SELECTION.instantiate()
					_float_tweak.get_node("Label").text = i.replacen("_", " ")
					_float_tweak.get_node("Label2").text = str(CharacterManager.suit_tweaks[_char][powerup_name][i])
					_float_tweak.tweak_name = i
					_float_tweak.get_node("Window/SpinBox").step = 1
					move_to.add_child(_float_tweak)
					Thunder.reorder_on_top_of(_float_tweak, h_separator_spawn)
		#for i in SkinsManager.suit_tweaks[SkinsManager.current_skin]:
			#print(i)
		#for i in move_to.get_children():
		#	if !i is MenuSelection: continue
		#	if "tweak_name" in i:
		#		i.is_toggled = i.tweak_name
	#elif !SkinsManager.current_skin:
		#return
		
	super(mouse_input)
	move_to.set_meta("_powerup_name", powerup_name)
	var _label = move_to.get_child(0).get_child(0)
	if _label && _label is Label:
		if !_label.has_meta("orig_text"):
			_label.set_meta("orig_text", _label.text)
		_label.text = _label.get_meta("orig_text", "%s") % powerup_name
	
	move_to._update_selectors()
	move_to.move_selector(0, true)
	print(move_to.selectors)
