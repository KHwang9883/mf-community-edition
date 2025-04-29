extends Node

const CATEGORY_SUIT_SELECTION = preload("res://stages/main_menu/objects/character_editor/category_suit_selection.tscn")

var skin_tweaks: Dictionary = {}

@onready var menu_controller: MenuItemsController = $"../.."
@onready var par: HSeparator = $".."

func _on_quick_skin_settings_button_selection_entered() -> void:
	get_tree().call_group(&"_skin_suit_category", &"queue_free")
	
	if SkinsManager.current_skin && SkinsManager.custom_textures.has(SkinsManager.current_skin):
		var _arr := PackedStringArray(SkinsManager.custom_textures[SkinsManager.current_skin].keys())
		_arr.sort()
		for i in _arr.size():
			var _cat_suit_sel = CATEGORY_SUIT_SELECTION.instantiate()
			_cat_suit_sel.powerup_name = _arr[i]
			_cat_suit_sel.get_node("Label").text = "%s suit" % [_arr[i].replacen("_", " ")]
			_cat_suit_sel.reset_to = _arr.size() - i + 2
			par.add_sibling(_cat_suit_sel)
	
	menu_controller._update_selectors()


func _on_exit_selection_entered() -> void:
	print("Skin Suit tweaks saved!")
	for powerup in skin_tweaks:
		var _skin_path = SkinsManager.base_dir \
			.path_join(SkinsManager.current_skin) \
			.path_join(powerup) \
			.path_join("suit_tweaks.json")
		SettingsManager.save_data(skin_tweaks[powerup], _skin_path, powerup, true)
		if !SkinsManager.suit_tweaks.has(SkinsManager.current_skin):
			SkinsManager.suit_tweaks[SkinsManager.current_skin] = {}
		SkinsManager.suit_tweaks[SkinsManager.current_skin][powerup] = skin_tweaks[powerup]
	
	skin_tweaks = {}
	
