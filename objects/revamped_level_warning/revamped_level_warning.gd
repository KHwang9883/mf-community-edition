extends Control

var opened: bool

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var v_box_container: MenuItemsController = $VBoxContainer

signal popped
signal closed

func _ready() -> void:
	animation_player.play(&"init")


func toggle(no_resume: bool = false, no_sound_effect: bool = false) -> void:
	if !v_box_container.focused && opened: return

	opened = !opened

	if opened:
		popped.emit()
	else:
		closed.emit()

	$'..'.offset = Vector2.ZERO

	if opened:
		v_box_container.move_selector(0, true)
		animation_player.play("open")
		SettingsManager.show_mouse()
	else:
		animation_player.play_backwards("open")
		SettingsManager.hide_mouse()
		v_box_container.focused = false

	for i in 2:
		await get_tree().physics_frame

	v_box_container.focused = opened
