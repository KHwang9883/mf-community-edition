extends Control

const MESSAGE_BLOCK = preload("res://engine/objects/bumping_blocks/message_block/message_block.wav")

var opened: bool

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var v_box_container: MenuItemsController = $VBoxContainer
@onready var _warn_tweak: bool = SettingsManager.get_tweak("show_warning_on_revamped_levels", true)
@onready var _remade_tweak: bool = SettingsManager.get_tweak("remade_levels", true)
@onready var label_11: Label = $Label11
@onready var revamp_warning: CanvasLayer = $".."

signal popped
signal closed
signal selected_new
signal selected_old

func _ready() -> void:
	animation_player.play(&"init")
	label_11.text = label_11.text.format([
		revamp_warning.revamp_first_part_text,
		revamp_warning.revamp_author_text
	])


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
		if !_warn_tweak:
			if _remade_tweak:
				selected_new.emit()
			else:
				selected_old.emit()
			return
		popped.emit()
		var _sfx = CharacterManager.get_sound_replace(MESSAGE_BLOCK, MESSAGE_BLOCK, "message_box", false)
		Audio.play_1d_sound(_sfx, true, {ignore_pause = true})
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
