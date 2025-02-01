extends Control

var opened: bool

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var v_box_container: MenuItemsController = $VBoxContainer

signal popped
signal closed
signal selected_new
signal selected_old

func _ready() -> void:
	animation_player.play(&"init")


func toggle(force_close: bool = false) -> void:
	if !v_box_container.focused && opened: return

	if force_close:
		opened = false
	else:
		opened = !opened

	if opened:
		if ProfileManager.current_profile.data.get("advanced_edition", null):
			selected_new.emit()
			print("[RevampMessage] Advanced Edition Forced to new Level Design.")
			return
		popped.emit()
		Audio.play_1d_sound(preload("res://objects/message_block/message_block.wav"), true, {ignore_pause = true})
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
		
	Scenes.custom_scenes.pause.open_blocked = opened
	get_tree().paused = opened

	for i in 2:
		await get_tree().physics_frame

	v_box_container.focused = opened
