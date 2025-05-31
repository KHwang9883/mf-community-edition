extends Control

var activated: bool
var antiafk_ref_node: Node

@onready var container: MenuItemsController = $ColorRect/HBoxContainer
@onready var label_error: Label = $LabelError

func _physics_process(delta: float) -> void:
	if !activated: return
	if Input.is_action_just_pressed(&"ui_cancel"):
		var tw = create_tween()
		tw.tween_property(self, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.tween_callback(queue_free)
		return

func activate() -> void:
	activated = true
	container.focused = true

func selected(item: Control) -> void:
	if !antiafk_ref_node: return
	item.name
