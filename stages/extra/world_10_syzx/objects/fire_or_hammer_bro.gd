extends Node2D

const HAMMER_BRO = preload("res://engine/objects/enemies/hammer_bros/hammer_bro.tscn")

@onready var _tweak: bool = SettingsManager.get_tweak("harder_level_design", false)

func _ready() -> void:
	if !_tweak: return
	for i in get_children():
		var rng_var: bool = bool(randi_range(0, 1))
		if !rng_var: continue
		
		var bro = HAMMER_BRO.instantiate()
		bro.global_position = i.global_position
		i.add_sibling(bro)
		i.queue_free()
