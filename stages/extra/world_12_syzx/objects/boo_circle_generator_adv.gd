@tool
extends "res://engine/objects/enemies/paratroopas/paratroopa_circle_generator.gd"

@onready var _tweak = ProfileManager.current_profile.data.get("advanced_edition", false)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	for i in amount:
		var angle: float = float(i) * (360 / float(amount))
		if !troopa: return
		var troopa_ins: Node2D = troopa.instantiate() as Node2D
		if !troopa_ins: return
		if !troopa_ins.is_in_group(&"#circle"): return
		troopa_ins.random_phase = false
		troopa_ins.amplitude = amplitude
		troopa_ins.phase = angle
		if _tweak:
			troopa_ins.frequency = frequency + (wrapi(i, 0, 3) / 2.0 * signf(frequency))
		else:
			troopa_ins.frequency = frequency
		add_child.call_deferred(troopa_ins)
