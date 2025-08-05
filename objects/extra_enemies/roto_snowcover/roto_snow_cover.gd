extends Node

const ZAMROZ = preload("res://objects/extra_enemies/roto_snowcover/zamrozic.wav")


func _ready() -> void:
	if !owner is Area2D: return
	
	owner.body_entered.connect(func(body: Node2D) -> void:
		if !(body is Player):
			return
		var wind_snow_cover := body.get_node_or_null(^"WindAndSnowCover")
		if !wind_snow_cover:
			return
		wind_snow_cover.snow_cover_accumulation += 0.5
		Audio.play_1d_sound(ZAMROZ)
	)
