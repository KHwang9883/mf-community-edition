extends "res://engine/objects/bosses/bowser/bowser_trigger.gd"

@export var trigger_bowser_2: Node2D


var triggered_bowser_2: bool

func _physics_process(delta: float) -> void:
	super(delta)
	if triggered && !triggered_bowser_2:
		var view: Rect2 = Rect2(get_viewport_transform().affine_inverse().get_origin(), get_viewport_rect().size)
		if trigger_bowser_2 && trigger_bowser_2.is_in_group(&"#bowser") && view.has_point(trigger_bowser_2.global_position):
			triggered_bowser_2 = true
			trigger_bowser_2.trigger = self
			trigger_bowser_2.activate()
