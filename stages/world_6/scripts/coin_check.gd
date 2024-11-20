extends Node2D

@onready var coins = get_children()
var sound_effect_played: bool

func _ready() -> void:
	if !SettingsManager.get_tweak("minigames_in_main_worlds", true):
		return
	child_exiting_tree.connect(_on_child_exiting_tree.unbind(1), CONNECT_DEFERRED)


func _on_child_exiting_tree() -> void:
	if get_child_count() > 0 || sound_effect_played:
		return
	
	Audio.play_1d_sound(preload("res://stages/extra/click_bonus_game/sfx/discoveredgunpowder-.wav"))
	sound_effect_played = true


func check_for_treasure() -> void:
	for i in get_children():
		if is_instance_valid(i) && i in coins:
			return
	
	Data.values.treasure = true
