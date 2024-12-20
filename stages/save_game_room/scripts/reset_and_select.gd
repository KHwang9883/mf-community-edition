extends "res://engine/scenes/save_game_room/scripts/reset.gd"

#var can_select: bool

@onready var _tweak: bool = SettingsManager.get_tweak("load_save_from_world_start", false)
@onready var unlock: Label = get_node_or_null(^"VBoxContainer/Unlock")
@onready var unlock2: Label = get_node_or_null(^"VBoxContainer/Unlock2")
@onready var secrets: Label = get_node_or_null(^"VBoxContainer/Secrets")

func _ready() -> void:
	super()
	move_down_by_px += 16
	if _tweak:
		unlock2.text = 'to select a level, disable the "always load first level" tweak'


func _physics_process(delta: float) -> void:
	if !is_inside: return
	super(delta)
	#if !can_select: return


func _on_pipe_save_player_enter() -> void:
	position.x = 0
	super()
	#move_down_by_px = first_pos + (16 * int(can_select))


func _player_enter_centered() -> void:
	_on_pipe_save_player_enter()
	position.x = -96
