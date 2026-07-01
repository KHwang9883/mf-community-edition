extends CanvasLayer

const MESSAGE_BLOCK = preload("res://engine/objects/bumping_blocks/message_block/message_block.wav")
const SELECT_ENTER = preload("res://engine/components/ui/_sounds/select_enter.wav")

var activated: bool

signal message_shown
signal message_hidden

@onready var box: Node2D = $Box
@onready var text: Label = $Box/Texture/Text
@onready var text_2: Label = $Box/Texture/Text3
@onready var label_2: Label = $"../Label2"
@onready var tweaks: Control = $"../SubViewportContainer/SubViewport/Tweaks"
@onready var parent: Control = $".."
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	reset_physics_interpolation()
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
	
	if Input.is_action_just_pressed(&"ui_select") || Input.is_action_just_pressed(&"ui_cancel") || Input.is_action_just_pressed(&"ui_accept"):
		hide_message()
		activated = false


func show_description(desc: String, title: String) -> void:
	message_shown.emit()
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


func hide_message() -> void:
	if !is_instance_valid(box): return
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
	)
