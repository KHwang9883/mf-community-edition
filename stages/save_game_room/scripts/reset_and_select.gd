extends "res://engine/scenes/save_game_room/scripts/reset.gd"

#var can_select: bool
@export var count_world_start_tweak: bool = true
@export var can_delete_save: bool = true

@onready var _tweak: bool = SettingsManager.get_tweak("load_save_from_world_start", false)
@onready var unlock: RichTextLabel = get_node_or_null(^"VBoxContainer/Unlock")
@onready var unlock2: RichTextLabel = get_node_or_null(^"VBoxContainer/Unlock2")
@onready var secrets: Label = get_node_or_null(^"VBoxContainer/Secrets")
@onready var deaths: Label = get_node_or_null(^"VBoxContainer/Deaths")

## 站上管道后整块重置面板淡入：删档提示、选世界（unlock）、选关卡（unlock2）
## 都在里面。触屏据此把 EXTRA 当作 Tab 来选关/选世界，并显示 F1/DEL 按键。
func is_level_select_shown() -> bool:
	return is_inside


func _ready() -> void:
	super()
	add_to_group(&"level_select_ui")
	move_down_by_px += 16
	if _tweak && count_world_start_tweak && unlock2:
		var msg := 'to select a level, disable the "always load first level" tweak'
		if unlock2.has_method(&"set_override_template"):
			unlock2.set_override_template(msg)
		else:
			unlock2.text = msg


func _physics_process(delta: float) -> void:
	if !is_inside: return
	if !can_delete_save: return
	super(delta)
	#if !can_select: return


func _on_pipe_save_player_enter() -> void:
	position.x = 0
	super()
	#move_down_by_px = first_pos + (16 * int(can_select))


func _player_enter_centered() -> void:
	_on_pipe_save_player_enter()
	position.x = -96
