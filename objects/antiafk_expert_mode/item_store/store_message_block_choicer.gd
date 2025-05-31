extends "res://engine/objects/bumping_blocks/message_block/message_block.gd"

const MID_LEVEL_ITEM_STORE = preload("res://objects/antiafk_expert_mode/item_store/mid_level_item_store.tscn")

signal choice_accepted
signal choice_canceled

@onready var antiafk_expert_mode: CanvasLayer = $".."

func _physics_process(delta: float) -> void:
	if !activated: return
	if !get_tree().paused:
		get_tree().paused = true
	if Input.is_action_just_pressed(&"ui_cancel"):
		hide_message()
		activated = false
		choice_canceled.emit()
		return
	if Input.is_action_just_pressed(&"ui_accept"):
		accepted()
		activated = false
		choice_accepted.emit()

func accepted() -> void:
	message_hidden.emit()
	box.scale = Vector2.ZERO
	box.reset_physics_interpolation()
	
	var item_store = MID_LEVEL_ITEM_STORE.instantiate()
	item_store.modulate.a = 0.0
	add_sibling(item_store)
	item_store.antiafk_ref_node = antiafk_expert_mode
	item_store.msgbox_ref_node = self
	var tw = item_store.create_tween()
	tw.tween_property(item_store, ^"modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_callback(item_store.activate)

func hide_message() -> void:
	if !is_instance_valid(box): return
	message_hidden.emit()
	
	var tw = get_tree().create_tween().bind_node(box)
	tw.tween_property(box, ^"scale", Vector2.ZERO, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.tween_callback(return_to_game)

func return_to_game() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().paused = false
	activated = false
	if "disable_pause_menu" in Scenes.current_scene:
		Scenes.current_scene.set(&"disable_pause_menu", _prev_pause_bool)
