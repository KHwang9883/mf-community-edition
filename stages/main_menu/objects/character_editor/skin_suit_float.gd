extends MenuSelection

@export var tweak_name: String
@export var tweak_parent_dict_name: String
@export_multiline var tweak_description_text: String

var is_blocked: bool
var is_toggled: bool
var cooldown: float = 0

@onready var spin_box: SpinBox = $Window/SpinBox

func _handle_focused(focus) -> void:
	super(focus)
	if !focus: return
	if tweak_description_text:
		$"../..".emit_signal(&"_tweak_desc", get_parent())


func _handle_select(mouse_input: bool = false) -> void:
	if is_blocked: return
	if cooldown > 0.0: return
	
	#var tweak = SettingsManager.get_tweak(tweak_name, default_value)
	if $Label2.text.is_valid_int():
		spin_box.value = int($Label2.text)
	elif $Label2.text.is_valid_float():
		spin_box.value = float($Label2.text)
	cooldown = 0.1
	$Window.visible = true
	get_tree().paused = true
	super(mouse_input)


func _physics_process(delta: float) -> void:
	super(delta)
	if cooldown > 0.0: cooldown -= delta
	if !focused || !get_parent().focused: return
	
	if Input.is_action_just_pressed(&"ui_select"):
		if tweak_description_text:
			$"../..".emit_signal(&"_show_desc", tweak_description_text, $Label.text)

func _handle_right_click() -> void:
	if focused && tweak_description_text:
		$"../..".emit_signal(&"_show_desc", tweak_description_text, $Label.text)


func _on_button_pressed() -> void:
	$Label2.text = str(spin_box.value)
	Audio.play_1d_sound(selected_sound, true, { "ignore_pause": true, "bus": "1D Sound" })
	var _quick_node = Scenes.current_scene.get_node("Tweaks/SubViewportContainer/SubViewport/Tweaks/QuickSkinSettings/HSeparatorSpawn/QuickSettingsScript")
	var powerup_name = get_parent().get_meta(&"_powerup_name")
	if !powerup_name: return
	_quick_node.skin_tweaks[powerup_name][tweak_name] = spin_box.value
