extends Control

const ITEM_RESERVE = preload("res://sfx/item-reserve.wav")
const INCORRECT = preload("res://engine/components/ui/_sounds/incorrect.wav")

var activated: bool
var antiafk_ref_node: Node
var store_inv: Dictionary
var _tw: Tween
var _inc_cd: float

@onready var container: MenuItemsController = $ColorRect/HBoxContainer
@onready var label_error: Label = $LabelError
@onready var error_str_toomuch: String = label_error.text
@onready var cost: Label = $Selector/Cost
@onready var label_6: Label = $Label6

func _physics_process(delta: float) -> void:
	if !activated: return
	if _inc_cd > 0: _inc_cd -= delta
	if Input.is_action_just_pressed(&"ui_cancel"):
		activated = false
		container.focused = false
		var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(self, "modulate:a", 0.0, 0.3)
		tw.tween_callback(queue_free)
		antiafk_ref_node.return_to_game()
		return

func activate() -> void:
	activated = true
	container.focused = true
	store_inv = antiafk_ref_node.store_inventory

func selected(item: Control) -> void:
	if !antiafk_ref_node || !activated: return
	var item_name: String = item.name
	if str(Data.values.item) == item_name:
		label_error.text = "you already have this item!"
		return _error_message()
	if Data.values.lives < store_inv[item_name]:
		label_error.text = error_str_toomuch
		return _error_message()
	
	var _sfx = CharacterManager.get_sound_replace(ITEM_RESERVE, ITEM_RESERVE, "bonus_reserve", false)
	Audio.play_1d_sound(_sfx, false, {ignore_pause = true})
	
	label_error.modulate.a = 0.0
	Data.values.item = str(item.name)
	Data.add_lives(-store_inv[item_name])
	var _hud = Thunder._current_hud
	if _hud && _hud.has_node("Control/MarioLives"):
		_hud.get_node("Control/MarioLives")._update_text()
	antiafk_ref_node.update_item_stock_content()
	
	var new_lbl = label_6.duplicate()
	new_lbl.text = "-%d" % store_inv[item_name]
	new_lbl.position = item.global_position + Vector2(8, 8)
	add_child(new_lbl)
	new_lbl.reset_physics_interpolation.call_deferred()
	
	$Label2.visible = false
	container.focused = false
	$ColorRect.modulate.a = 0.5
	cost.visible = false
	$Selector.visible = false
	var _label3_tw = $Label3.create_tween().set_loops().set_trans(Tween.TRANS_CUBIC)
	_label3_tw.tween_property($Label3, "modulate:a", 0.3, 0.5)
	_label3_tw.tween_property($Label3, "modulate:a", 1.0, 0.5)
	
	var tw = new_lbl.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(new_lbl, "position:y", new_lbl.position.y - 48, 1.0)
	tw.tween_interval(2.5)
	tw.tween_property(new_lbl, "modulate:a", 0.0, 0.5)
	tw.tween_callback(new_lbl.queue_free)


func _on_selected(item_index: int, item_node: Control, immediate: bool, mouse_input: bool) -> void:
	if !store_inv: return
	var life_count: int = store_inv.get(item_node.name)
	cost.text = "costs %d %s" % [life_count, "life" if life_count == 1 else "lives"]

func _error_message() -> void:
	label_error.modulate.a = 1.0
	if _tw: _tw.kill()
	_tw = create_tween()
	_tw.tween_interval(2.0)
	_tw.tween_property(label_error, "modulate:a", 0.0, 1.0)
	if _inc_cd > 0: return
	var inc_sfx = CharacterManager.get_sound_replace(INCORRECT, INCORRECT, "menu_failure", false)
	Audio.play_1d_sound(inc_sfx, false, {ignore_pause = true})
	_inc_cd = 0.5
	
