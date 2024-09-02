extends "res://engine/scenes/save_game_room/scripts/reset.gd"

#var can_select: bool

@onready var _tweak: bool = SettingsManager.get_tweak("load_save_from_world_start", false)

func _ready() -> void:
	move_down_by_px += 16


func _physics_process(delta: float) -> void:
	if !is_inside: return
	super(delta)
	#if !can_select: return


func _on_pipe_save_player_enter() -> void:
	super()
	#move_down_by_px = first_pos + (16 * int(can_select))
