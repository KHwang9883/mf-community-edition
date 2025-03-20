extends "res://stages/main_menu/scripts/tweak_category_sel.gd"

@export var powerup_name: String


func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	move_to.set_meta("_powerup_name", powerup_name)
	var _label = move_to.get_child(0).get_child(0)
	if _label && _label is Label:
		if !_label.has_meta("orig_text"):
			_label.set_meta("orig_text", _label.text)
		_label.text = _label.get_meta("orig_text", "%s") % powerup_name
	
	SkinsManager.suit_tweaks
	
	for i in move_to.get_children():
		if !i is MenuSelection: continue
		if "tweak_name" in i:
			i.is_toggled = i.tweak_name
