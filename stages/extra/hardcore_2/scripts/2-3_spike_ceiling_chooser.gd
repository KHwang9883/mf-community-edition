extends Node2D

@onready var spike_ceiling: VBoxContainer = $SpikeCeiling
@onready var v_box_container: Control = $VBoxContainer

func _ready() -> void:
	if !OS.has_feature("template") && Input.is_action_pressed("a_delete"):
		KevinGlobal.activated = true
	
	if KevinGlobal.activated:
		spike_ceiling.queue_free()
		v_box_container.modulate.a = 1.0
	else:
		v_box_container.queue_free()
		spike_ceiling.modulate.a = 1.0
