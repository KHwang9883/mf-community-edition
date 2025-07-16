@tool
extends "res://engine/objects/warps/pipe_in.gd"

signal tried_to_enter

#@export_node_path("StaticBumpingBlock") var choicer_node_path: NodePath
var choicer_node: StaticBumpingBlock
var _prev_lr: float
var _prev_ud: float
var _temp_warp: bool
var _is_message_open: bool

func _ready() -> void:
	super()
	
	if Engine.is_editor_hint(): return
	var ow_unlocker = Scenes.custom_scenes.get("otherworld_unlocker")
	if !is_instance_valid(ow_unlocker):
		return printerr(name, ":OW Unlocker not defined")
	
	choicer_node = ow_unlocker.get_node("MessageBlockChoicer")
	if !is_instance_valid(choicer_node):
		return printerr(name, ":Choicer not defined")
	Thunder._connect(choicer_node.choice_accepted, _on_choice_accepted)
	Thunder._connect(choicer_node.choice_canceled, _on_choice_canceled)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		_label()
		return
	if !player: return
	if !choicer_node: return
	if !_is_message_open && has_tried_to_enter():
		_is_message_open = true
		choicer_node.show_message.call_deferred()
		tried_to_enter.emit()
		player.left_right = 0
		player.up_down = 0
	#_warp_initiator()

	if !_on_warp: return
	_warping_process(delta)


func _on_choice_accepted() -> void:
	if !player: return
	player.left_right = _prev_lr
	player.up_down = _prev_ud
	_warp_initiator()
	_is_message_open = false

func _on_choice_canceled() -> void:
	if !player: return
	_is_message_open = false


func has_tried_to_enter() -> bool:
	if _on_warp || player.warp != Player.Warp.NONE:
		return false
	_temp_warp = false
	
	var input_x: float = player.left_right
	var input_y: float = player.up_down

	if input_x > 0 && warp_direction == Player.WarpDir.RIGHT && player.is_on_floor():
		_temp_warp = true
	elif input_x < 0 && warp_direction == Player.WarpDir.LEFT && player.is_on_floor():
		_temp_warp = true
	if input_y > 0 && warp_direction == Player.WarpDir.DOWN:
		_temp_warp = true
	elif input_y < 0 && warp_direction == Player.WarpDir.UP:
		_temp_warp = true
	if _temp_warp:
		_prev_lr = input_x
		_prev_ud = input_y
	return _temp_warp
