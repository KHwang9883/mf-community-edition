extends Area2D

const coin_effect: PackedScene = preload("res://engine/objects/effects/coin_effect/coin_effect.tscn")

const DRAGON_COIN = preload("res://objects/dragon_coin/dragon_coin.wav")

@onready var enemy_attacked: Node = $Body/EnemyAttacked
#@export var sound: AudioStream = DRAGON_COIN

func _ready() -> void:
	#var _custom_sound = CharacterManager.get_sound_replace(enemy_attacked.killing_sound_succeeded, DRAGON_COIN, "coin", false)
	enemy_attacked.killing_sound_succeeded = DRAGON_COIN
	if Data.values.dragon_coin_life:
		queue_free()
		return
	if Data.values.checkpoint != -1:
		if !get_path() in Data.values.dragon_coins_array:
			queue_free()


func _play_sound() -> void:
	#var _custom_sound = CharacterManager.get_sound_replace(sound, DRAGON_COIN, "coin", false)
	Audio.play_sound(DRAGON_COIN, self, false)


func _from_bumping_block() -> void:
	_play_sound()
	NodeCreator.prepare_2d(coin_effect, self).create_2d().bind_global_transform()
	Data.add_coin()
	queue_free()


func _physics_process(delta):
	if !Thunder._current_player: return
	if overlaps_body(Thunder._current_player):
		collect()


func collect() -> void:
	if !"dragon_coins" in Data.values: Data.values.dragon_coins = 0
	if !"dragon_coins_max" in Data.values: Data.values.dragon_coins_max = 3
	Data.values.dragon_coins += 1
	Data.emit_signal(&"dragon_coin_collected")
	if !Data.values.get("dragon_coin_life", false) && Data.values.dragon_coins >= Data.values.dragon_coins_max:
		Data.values.dragon_coin_life = true
		Thunder.add_lives(1)
		var _sfx = CharacterManager.get_sound_replace(Data.LIFE_SOUND, Data.LIFE_SOUND, "1up", false)
		Audio.play_1d_sound(_sfx, false)
	
	Data.add_score(1000)
	ScoreText.new("1000", self)
	
	if SettingsManager.get_quality() != SettingsManager.QUALITY.MIN:
		NodeCreator.prepare_2d(coin_effect, self).call_method( func(eff: Node2D) -> void:
			eff.explode()
		).create_2d().bind_global_transform()
	
	_play_sound()
	queue_free()
