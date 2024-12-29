@icon("res://engine/objects/warps/icons/pipe_in.svg")
@tool
extends Area2D

@export_category("Warp")
@export_group("General")
@export var warp_direction: Player.WarpDir = Player.WarpDir.DOWN

var player: Player

var _on_warp: bool

signal player_enter
signal player_exit
signal warp_started

func _ready() -> void:
	if Engine.is_editor_hint(): return

	$TextDir.queue_free()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		_label()
		return
	if !player: return
	_warp_initiator()


func _warp_initiator() -> void:
	if _on_warp || player.warp != Player.Warp.NONE:
		return
	
	var input_x: float = player.left_right
	var input_y: float = player.up_down

	if input_x > 0 && warp_direction == Player.WarpDir.RIGHT && player.is_on_floor():
		_on_warp = true
	elif input_x < 0 && warp_direction == Player.WarpDir.LEFT && player.is_on_floor():
		_on_warp = true
	if input_y > 0 && warp_direction == Player.WarpDir.DOWN:
		_on_warp = true
	elif input_y < 0 && warp_direction == Player.WarpDir.UP:
		_on_warp = true

	if _on_warp:
		warp_started.emit()
		await get_tree().physics_frame
		_on_warp = false


func _label() -> void:
	var text: Label = $TextDir
	text.rotation = -global_rotation
	text.scale = Vector2.ONE / 1.5
	match warp_direction:
		Player.WarpDir.RIGHT: text.text = "right"
		Player.WarpDir.LEFT: text.text = "left"
		Player.WarpDir.UP: text.text = "up"
		Player.WarpDir.DOWN: text.text = "down"
		_: ""


func _on_body_entered(body: Node2D) -> void:
	if Engine.is_editor_hint(): return
	if body == Thunder._current_player:
		player = body
		player_enter.emit()

func _on_body_exited(body: Node2D) -> void:
	if Engine.is_editor_hint(): return
	if body == Thunder._current_player:
		_on_warp = false
		player = null
		player_exit.emit()
