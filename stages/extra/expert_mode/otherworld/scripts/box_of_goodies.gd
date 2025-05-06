extends Node

const GUNPICKUP_2 = preload("res://sfx/gunpickup2.wav")
const FUN = preload("res://sfx/fun.ogg")

@onready var area_2d: Area2D = $"../Area2D"


func _ready() -> void:
	area_2d.visible = true


func _on_area_2d_player_enter() -> void:
	Audio.play_1d_sound(GUNPICKUP_2, false)
	
	if !area_2d: return
	area_2d.queue_free()
	
	Thunder.add_score(1000000)
	Data.add_coin(10)
	var player: Player = Thunder._current_player
	if !player:
		return
	var suit = CharacterManager.get_suit("boomerang")
	Thunder._current_player.change_suit(suit, false, true)
	


func _on_figa_player_enter() -> void:
	Audio.play_1d_sound(FUN, false)
	$Untitled.visible = true
