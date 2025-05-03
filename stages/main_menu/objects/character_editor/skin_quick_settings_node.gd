extends Node

const CATEGORY_SUIT_SELECTION = preload("res://stages/main_menu/objects/character_editor/category_suit_selection.tscn")
const SKIN_SETTINGS_GLOBAL = preload("res://stages/main_menu/objects/character_editor/skin_settings_global.tscn")

var skin_tweaks: Dictionary = {}

@onready var menu_controller: MenuItemsController = $"../.."
@onready var par: HSeparator = $".."
@onready var camera_2d: Camera2D = $"../../../Camera2D"

func _on_quick_skin_settings_button_selection_entered() -> void:
	get_tree().call_group(&"_skin_suit_category", &"queue_free")
	
	if SkinsManager.current_skin && SkinsManager.custom_textures.has(SkinsManager.current_skin):
		var _arr := PackedStringArray(SkinsManager.custom_textures[SkinsManager.current_skin].keys())
		_arr.sort()
		for i in _arr.size():
			var _cat_suit_sel = CATEGORY_SUIT_SELECTION.instantiate()
			_cat_suit_sel.powerup_name = _arr[i]
			_cat_suit_sel.get_node("Label").text = "%s suit" % [_arr[i].replacen("_", " ")]
			_cat_suit_sel.reset_to = _arr.size() - i + 1
			par.add_sibling(_cat_suit_sel)
	elif SkinsManager.current_skin.is_empty():
		var _cat_suit_sel = SKIN_SETTINGS_GLOBAL.instantiate()
		par.add_sibling(_cat_suit_sel)
		
	
	menu_controller._update_selectors()
	_resize_quick_skin()


func _on_exit_selection_entered() -> void:
	print("Skin Suit tweaks saved!")
	for powerup in skin_tweaks:
		var _skin_path: String
		var _current_skin = SkinsManager.current_skin
		if !_current_skin:
			_current_skin = "none"
			powerup = "global"
		_skin_path = SkinsManager.base_dir \
			.path_join(_current_skin) \
			.path_join(powerup) \
			.path_join("suit_tweaks.json")
		SettingsManager.save_data(skin_tweaks[powerup], _skin_path, powerup, true)
		if !SkinsManager.suit_tweaks.has(_current_skin):
			SkinsManager.suit_tweaks[_current_skin] = {}
		var file_path: String = SkinsManager.base_dir + "/" + _current_skin + "/" + powerup
		if _current_skin == "none":
			SkinsManager._load_suit_tweaks(_current_skin, powerup, file_path)
			break
		else:
			SkinsManager.suit_tweaks[_current_skin][powerup] = skin_tweaks[powerup]
	
	skin_tweaks = {}
	


func _on_submenu_exit_selection_entered() -> void:
	get_tree().call_group(&"_submenu_skin_suit_category", &"queue_free")
	menu_controller.size.y = 432
	_resize_skin_suit()


func _resize_skin_suit() -> void:
	# WHAT THE FUCK IS WRONG
	for i in 8:
		if !is_inside_tree(): return
		var _control: Control = $"../../../SkinSuitSettings"
		#print(_control.get_combined_minimum_size().y)
		if !_control.focused && i > 2: return
		if _control.size.y > _control.get_combined_minimum_size().y:
			_control.size.y = _control.get_combined_minimum_size().y
		camera_2d.update_limit()
		await get_tree().physics_frame


func _resize_submenu() -> void:
	for i in 8:
		if !is_inside_tree(): return
		var _control: Control = $"../../../SkinSuitSettingsSubmenu"
		#print(_control.get_combined_minimum_size().y)
		if !_control.focused && i > 2: return
		if _control.size.y > _control.get_combined_minimum_size().y:
			_control.size.y = _control.get_combined_minimum_size().y
		camera_2d.update_limit()
		await get_tree().physics_frame


func _resize_quick_skin() -> void:
	for i in 8:
		if !is_inside_tree(): return
		var _control: Control = $"../../../QuickSkinSettings"
		#print(_control.get_combined_minimum_size().y)
		if !_control.focused && i > 2: return
		if _control.size.y > _control.get_combined_minimum_size().y:
			_control.size.y = _control.get_combined_minimum_size().y
		camera_2d.update_limit()
		await get_tree().physics_frame


func _on_skin_suit_exit_selection_entered() -> void:
	_resize_quick_skin()
