extends Area2D

const coin_effect: PackedScene = preload("res://engine/objects/effects/coin_effect/coin_effect.tscn")

@export var sound: AudioStream = preload("res://engine/objects/items/coin/coin.wav")
@onready var parent: Node = $'..'

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collect()

func collect() -> void:
	Thunder.add_score(200)
	
	NodeCreator.prepare_2d(coin_effect, self).call_method( func(eff: Node2D) -> void:
		eff.explode()
	).create_2d().bind_global_transform()
	
	Audio.play_sound(sound, self, false)
	parent.queue_free()

func collect_bump() -> void:
	NodeCreator.prepare_2d(coin_effect, self).call_method( func(eff: Node2D) -> void:
		eff.score_given = 200
	).create_2d().bind_global_transform()
	
	Audio.play_sound(sound, self, false)
	parent.queue_free()
	
