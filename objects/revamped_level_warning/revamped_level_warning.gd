extends Control

const MESSAGE_BLOCK = preload("res://engine/objects/bumping_blocks/message_block/message_block.wav")

var opened: bool
var message_activated: bool
var controls_blocked: bool
@warning_ignore("unused_private_class_variable")
var _improved_levels: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var v_box_container: MenuItemsController = $VBoxContainer
@onready var _warn_tweak: bool = SettingsManager.get_tweak("show_warning_on_revamped_levels", true)
@onready var _remade_tweak: bool = SettingsManager.get_tweak("remade_levels", true)
@onready var label_11: RichTextLabel = $Label11
@onready var revamp_warning: CanvasLayer = $".."
@onready var text: Label = $CanvasLayer/Box/Texture/Text
@onready var box: Node2D = $CanvasLayer/Box
@onready var texture_rect: TextureRect = $VBoxContainer/TextureRect

signal popped
signal closed
signal selected_new
signal selected_old

func _ready() -> void:
	animation_player.play(&"init")
	text.text = text.text.format([
		revamp_warning.revamp_first_part_text,
		revamp_warning.revamp_second_part_text
	])
	if !revamp_warning.recommended_button:
		var _rvp_texture: AtlasTexture = texture_rect.texture.duplicate(true)
		_rvp_texture.region = Rect2(0, 192, 250, 30)
		texture_rect.texture = _rvp_texture


func toggle(force_close: bool = false) -> void:
	if !v_box_container.focused && opened: return
	if message_activated: return

	if force_close:
		opened = false
	else:
		opened = !opened

	if opened:
		#if ProfileManager.current_profile.data.get("advanced_edition", null):
			#selected_new.emit()
			#print("[RevampMessage] Advanced Edition Forced to new Level Design.")
			#return
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


func _physics_process(delta: float) -> void:
	if controls_blocked: return
	if !opened: return
	if !message_activated:
		if Input.is_action_just_pressed(&"ui_select"):
			show_message()
			controls_blocked = true
			v_box_container.focused = false
		return
	
	for i in [&"ui_select", &"ui_accept", &"m_jump", &"ui_cancel"]:
		if Input.is_action_just_pressed(i):
			hide_message()
			controls_blocked = true
			break

func show_message() -> void:
	box.scale = Vector2.ZERO
	var _sfx = CharacterManager.get_sound_replace(MESSAGE_BLOCK, MESSAGE_BLOCK, "message_box", false)
	Audio.play_1d_sound(_sfx, true, {ignore_pause = true})
	
	box.position = get_viewport_rect().get_center()
	box.reset_physics_interpolation()
	box.get_child(0).reset_physics_interpolation()
	
	var tw = get_tree().create_tween().bind_node(box).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(box, ^"scale", Vector2.ONE, 0.5)
	tw.tween_callback(func():
		message_activated = true
		controls_blocked = false
	)


func hide_message() -> void:
	var tw = get_tree().create_tween().bind_node(box)
	tw.tween_property(box, ^"scale", Vector2.ZERO, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.tween_callback(func():
		message_activated = false
		v_box_container.focused = true
		controls_blocked = false
	)
