extends MenuSelection

@export_multiline var tweak_description_text: String
@onready var valu = get_node_or_null(^"Value")
var _timer: float
@onready var skin_room: CanvasLayer = $"../../SkinRoom"
@onready var canvas_lay = Scenes.current_scene.get_node(^"Tweaks/CanvasLayer")
@onready var message_block_choicer: AnimatableBody2D = canvas_lay.get_node(^"MessageBlockChoicer")
@onready var choicer_bg: ColorRect = canvas_lay.get_node(^"ColorRect")
var _block_desc: bool

func _ready() -> void:
	Thunder._connect(message_block_choicer.message_hidden, _choicer_bg_hide)
	message_block_choicer.get_node("CanvasLayer").layer = 5
	if valu:
		valu.modulate.a = 0.0
		_template = valu.text
		_update_text()
		SettingsManager.settings_saved.connect(_update_text)


func _choicer_bg_show() -> void:
	choicer_bg.color.a = 0
	var tw = message_block_choicer.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tw.tween_property(choicer_bg, "color:a", 0.5, 0.3)

func _choicer_bg_hide() -> void:
	choicer_bg.color.a = 0.5
	var tw = message_block_choicer.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tw.tween_property(choicer_bg, "color:a", 0.0, 0.3)
	_block_desc = false


func _physics_process(delta: float) -> void:
	super(delta)
	if focused && get_parent().focused:
		if _block_desc: return
		if Input.is_action_just_pressed(&"ui_select") && tweak_description_text:
			$"../..".emit_signal(&"_show_desc", tweak_description_text, $Label.text)
	
	if !valu:
		return
	if focused:
		_timer += delta * 10
		valu.modulate.a = min((cos(_timer) / 2.5) + 0.6, 1.0)
	else:
		valu.modulate.a = 0.0

func _handle_focused(focus) -> void:
	super(focus)
	if !focus: return
	if tweak_description_text:
		$"../..".emit_signal(&"_tweak_desc", get_parent())

func _handle_right_click() -> void:
	if focused && get_parent().focused && tweak_description_text:
		if _block_desc: return
		$"../..".emit_signal(&"_show_desc", tweak_description_text, $Label.text)

func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	_block_desc = true
	Thunder._connect(message_block_choicer.choice_accepted, accept)
	message_block_choicer.show_message.call_deferred()
	_choicer_bg_show()


func accept():
	var pck_arg: PackedStringArray = ["--main-pack","mfce-skin-editor.pck"]
	var pid := OS.create_instance(pck_arg)
	if pid != -1:
		get_tree().quit()


var _template: String
func _update_text() -> void:
	var _events: Array[InputEvent] = InputMap.action_get_events(&"ui_accept")
	var _event: String = "enter"
	var _temp: String
	for i in _events:
		if i is InputEventKey:
			_temp = i.as_text().get_slice(' (', 0)
			#if SettingsManager.device_keyboard:
			_event = _temp
			break
		#elif i is InputEventJoypadButton:
		#	_temp = "Joy " + str(i.button_index)
		if _temp: _event = _temp
	
	valu.text = _template % [_event]
