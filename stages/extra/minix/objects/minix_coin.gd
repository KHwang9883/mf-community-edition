extends Area2D

const coin_effect: PackedScene = preload("res://engine/objects/effects/coin_effect/coin_effect.tscn")

const DEFAULT_SOUND = preload("res://engine/objects/items/coin/coin.wav")

@onready var parent: Node = $'..'
@export var sound: AudioStream = DEFAULT_SOUND

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collect()

func _play_sound() -> void:
	var _custom_sound = CharacterManager.get_sound_replace(sound, DEFAULT_SOUND, "coin", false)
	Audio.play_sound(_custom_sound, self, false)

func collect() -> void:
	Thunder.add_score(200)
	
	if SettingsManager.get_quality() != SettingsManager.QUALITY.MIN:
		NodeCreator.prepare_2d(coin_effect, self).call_method( func(eff: Node2D) -> void:
			eff.explode()
		).create_2d().bind_global_transform()
	
	_play_sound()
	parent.queue_free()

func collect_bump() -> void:
	NodeCreator.prepare_2d(coin_effect, self).call_method( func(eff: Node2D) -> void:
		eff.score_given = 200
	).create_2d().bind_global_transform()
	
	_play_sound()
	parent.queue_free()
	
