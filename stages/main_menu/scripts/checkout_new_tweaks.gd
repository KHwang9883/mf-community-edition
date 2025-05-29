extends Node2D

const CURRENT_TWEAKS_VERSION: int = 1

@onready var checkout: Sprite2D = $Checkout
@onready var tweaks_sel: MenuSelection = $"../../Menu/MainMenuControls/Tweaks"

func _ready() -> void:
	hide()
	checkout._min_a = 0.6

func hide_and_save() -> void:
	SettingsManager.set_custom_setting("new_tweaks_notification", CURRENT_TWEAKS_VERSION)
	hide()


func _on_menu_initiated() -> void:
	if SettingsManager.get_custom_setting("new_tweaks_notification", 0) >= CURRENT_TWEAKS_VERSION:
		return
	show()
	tweaks_sel.has_entered.connect(hide_and_save, CONNECT_ONE_SHOT)
