extends CanvasLayer

const MESSAGE_BLOCK = preload("res://engine/objects/bumping_blocks/message_block/message_block.wav")
const SELECT_ENTER = preload("res://engine/components/ui/_sounds/select_enter.wav")

var activated: bool
## Confirmation mode: A (ui_accept) confirms, B (ui_cancel) cancels instead of
## closing on any key like a regular description.
var _confirm_mode := false
var _confirm_callback := Callable()
var _pending_confirm := Callable()
var _pending_result := false
var _hint_label: Node
var _hint_keyboard := ""
var _hint_joypad := ""
var _hint_input := ""
var _hint_saved := false

signal message_shown
signal message_hidden

@onready var box: Node2D = $Box
@onready var text: Label = $Box/Texture/Text
@onready var text_2: Label = $Box/Texture/Text3
@onready var label_2: Control = $"../Label2"
@onready var tweaks: Control = $"../SubViewportContainer/SubViewport/Tweaks"
@onready var parent: Control = $".."
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	reset_physics_interpolation()
	hide()
	box.scale = Vector2.ZERO
	label_2.visible = false
	tweaks.add_user_signal("_tweak_desc")
	tweaks.add_user_signal("_show_desc")
	for i in tweaks.get_children():
		if i is MenuItemsController:
			i.connect(&"selected", _set_invis.unbind(4))
	tweaks.connect(&"_tweak_desc", func(controller):
		if controller.focused:
			label_2.visible = true
	)
	tweaks.connect(&"_show_desc", show_description)
	SettingsManager.mouse_pressed.connect(func(index: int):
		if box.scale.x < 0.5: return
		if index == MOUSE_BUTTON_LEFT && activated:
			hide_message()
			activated = false
	)


func _set_invis() -> void:
	label_2.visible = false


func _physics_process(delta: float) -> void:
	if !activated: return
	if !get_tree().paused:
		get_tree().paused = true
	
	if box.scale.x < 0.5:
		return
	
	if _confirm_mode:
		if Input.is_action_just_pressed(&"ui_accept"):
			_resolve_confirmation(true)
		elif Input.is_action_just_pressed(&"ui_cancel"):
			_resolve_confirmation(false)
		return
	
	if Input.is_action_just_pressed(&"ui_select") || Input.is_action_just_pressed(&"ui_cancel") || Input.is_action_just_pressed(&"ui_accept"):
		hide_message()
		activated = false


func show_description(desc: String, title: String) -> void:
	message_shown.emit()
	show()
	reset_physics_interpolation()
	box.scale = Vector2.ZERO
	var btexture: TextureRect = $Box/Texture
	text.text = desc
	text_2.text = title
	text.size.y = 0
	btexture.size.y = text.size.y + 16
	btexture.position.y = btexture.size.y / -2
	text.position.y = -2
	text.size.y = 0
	text.size.y += 16
	text.reset_physics_interpolation()
	btexture.reset_physics_interpolation()
	#$Box/Texture.size.y = text.get_line_height() * text.get_line_count() + 8
	process_mode = Node.PROCESS_MODE_ALWAYS
	var _sfx = CharacterManager.get_sound_replace(MESSAGE_BLOCK, MESSAGE_BLOCK, "message_box", false)
	Audio.play_1d_sound(_sfx, true, {ignore_pause = true})
	get_tree().paused = true
	
	box.position = Vector2(320, 240)
	box.reset_physics_interpolation()
	
	var tw2 = get_tree().create_tween().bind_node(color_rect).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw2.tween_property(color_rect, ^"color:a", 0.5, 0.5)
	
	var tw = get_tree().create_tween().bind_node(box).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(box, ^"scale", Vector2.ONE, 0.5)
	tw.tween_callback(func():
		activated = true
		
	)


## Reuses this box for a yes/no prompt: same pop animation, sound and background,
## but A (ui_accept) confirms and B (ui_cancel) cancels. [param on_result] runs
## after the box has closed and the tree is unpaused again.
func show_confirmation(desc: String, title: String, hint: String, on_result: Callable) -> void:
	_confirm_mode = true
	_confirm_callback = on_result
	_pending_confirm = Callable()
	_pending_result = false
	_hint_label = get_node_or_null(NodePath("Box/Texture/Text2"))
	if _hint_label != null:
		if !_hint_saved:
			_hint_keyboard = _hint_label.get(&"text_keyboard")
			_hint_joypad = _hint_label.get(&"text_joypad")
			# The in-box hint has empty device templates, so its rendered text
			# comes from input_template and has to be restored explicitly.
			_hint_input = _hint_label.get(&"input_template")
			_hint_saved = true
		_hint_label.set(&"text_keyboard", hint)
		_hint_label.set(&"text_joypad", hint)
		_hint_label.call(&"update_text")
	show_description(desc, title)


func _resolve_confirmation(confirmed: bool) -> void:
	if !_confirm_mode:
		return
	_confirm_mode = false
	_pending_confirm = _confirm_callback
	_pending_result = confirmed
	_confirm_callback = Callable()
	hide_message()


func hide_message() -> void:
	if !is_instance_valid(box): return
	# Closing without choosing a button (e.g. a click on the box) counts as cancel.
	if _confirm_mode:
		_confirm_mode = false
		_pending_confirm = _confirm_callback
		_pending_result = false
		_confirm_callback = Callable()
	message_hidden.emit()
	var _sfx = CharacterManager.get_sound_replace(SELECT_ENTER, SELECT_ENTER, "menu_enter", false)
	Audio.play_1d_sound(_sfx, false, {ignore_pause = true})
	
	var tw2 = get_tree().create_tween().bind_node(color_rect).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw2.tween_property(color_rect, ^"color:a", 0.0, 0.5)
	
	var tw = get_tree().create_tween().bind_node(box)
	tw.tween_property(box, ^"scale", Vector2.ZERO, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.tween_callback(func():
		#box.reparent(self)
		#box = $Box
		process_mode = Node.PROCESS_MODE_INHERIT
		get_tree().paused = false
		activated = false
		_restore_hint()
		_flush_confirmation()
	)


func _restore_hint() -> void:
	if !_hint_saved || !is_instance_valid(_hint_label):
		return
	_hint_saved = false
	_hint_label.set(&"text_keyboard", _hint_keyboard)
	_hint_label.set(&"text_joypad", _hint_joypad)
	_hint_label.set(&"input_template", _hint_input)
	_hint_label.call(&"update_text")


func _flush_confirmation() -> void:
	var callback := _pending_confirm
	_pending_confirm = Callable()
	var result := _pending_result
	_pending_result = false
	if callback.is_valid():
		callback.call(result)
