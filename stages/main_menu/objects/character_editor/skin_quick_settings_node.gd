extends Node

const CATEGORY_SUIT_SELECTION = preload("res://stages/main_menu/objects/character_editor/category_suit_selection.tscn")

@onready var menu_controller: MenuItemsController = $"../.."
@onready var par: HSeparator = $".."

func _on_quick_skin_settings_button_selection_entered() -> void:
	get_tree().call_group(&"_skin_suit_category", &"queue_free")
	
	if SkinsManager.current_skin && SkinsManager.suit_tweaks.has(SkinsManager.current_skin):
		for i in SkinsManager.suit_tweaks[SkinsManager.current_skin]:
			var _cat_suit_sel = CATEGORY_SUIT_SELECTION.instantiate()
			_cat_suit_sel.powerup_name = i
			_cat_suit_sel.get_node("Label").text = "%s suit" % [i]
			par.add_sibling(_cat_suit_sel)
	
	menu_controller._update_selectors.call_deferred()
