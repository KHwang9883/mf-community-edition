extends InputRichTextLabel

@export_multiline var text_keyboard: String = ""
@export_multiline var text_joypad: String = ""

var _tw: Tween
var _min_a: float = 0


func _ready() -> void:
	modulate.a = 0
	_apply_device_template()
	super._ready()


func update_text() -> void:
	_apply_device_template()
	super.update_text()


func _physics_process(_delta: float) -> void:
	if _tw:
		return
	
	_tw = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	_tw.tween_property(self, ^"modulate:a", 1, 0.5)
	_tw.tween_property(self, ^"modulate:a", _min_a, 0.5)


func _apply_device_template() -> void:
	if SettingsManager.device_keyboard:
		if !text_keyboard.is_empty():
			input_template = text_keyboard
	elif !text_joypad.is_empty():
		input_template = text_joypad
