extends "res://gfx/fancy_graphics/scripts/plushy_sun.gd"

var passed: bool

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var effect: Node2D = $Effect
@onready var bonus_level_unlocked: Sprite2D = Thunder._current_hud.get_node("BonusLevelUnlocked")

func _ready() -> void:
	if !SettingsManager.get_tweak("minigames_in_main_worlds", true) || ("bonus_game" in Data.values && Data.values.bonus_game):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if passed: return
	if body != Thunder._current_player: return
	
	Audio.play_1d_sound(preload("res://stages/extra/click_bonus_game/sfx/bonus_super_coin_collect-.wav"), false, { "bus": "1D Sound" })
	Data.values.bonus_game = true
	passed = true
	
	bonus_level_unlocked.activate()
	var tw = create_tween().set_parallel()
	tw.tween_property(sprite_2d, "modulate:a", 0.0, 2.0)
	tw.tween_property(effect, "modulate:a", 0.0, 1.5)
	tw.tween_property(effect, "scale", Vector2.ZERO, 2.0)
	
	await tw.finished
	queue_free()
