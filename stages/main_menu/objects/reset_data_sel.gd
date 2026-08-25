extends MenuSelection

@onready var window: Window = $Window
@onready var valu: Label = $Value
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog
@onready var v_box_container: VBoxContainer = $Window/Control/VBoxContainer/VBoxContainer

var _timer: float
var stored_reset_type: String
var ctrl_buttons: Array[Button]


func _ready() -> void:
	valu.modulate.a = 0.0
	_template = valu.text
	_update_text()
	SettingsManager.settings_saved.connect(_update_text)
	window.hide()
	for i in v_box_container.get_children():
		if !i is Button || !i.visible: continue
		if i is CheckBox: continue
		ctrl_buttons.append(i)
		Thunder._connect(i.pressed, _on_reset_btn_pressed.bind(i.name, i.text))

func _on_reset_btn_pressed(what: String, text: String) -> void:
	if !what: return
	stored_reset_type = what
	confirmation_dialog.dialog_text = "Really %s?" % [text]
	if what in ["Tweaks", "Settings"]:
		confirmation_dialog.dialog_text += "\nThe game will be restarted."
	confirmation_dialog.show()
	var win_scale = SettingsManager.get_ui_scale(confirmation_dialog)
	SettingsManager.scale_window(confirmation_dialog, win_scale)
	confirmation_dialog.move_to_center()
	confirmation_dialog.grab_focus()

func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	
	window.show()
	var win_scale = SettingsManager.get_ui_scale(window)
	SettingsManager.scale_window(window, win_scale)
	window.move_to_center()
	window.grab_focus()

func _physics_process(delta: float) -> void:
	super(delta)
	if window.visible || !focused:
		valu.modulate.a = 0
		return
	
	_timer += delta * 10
	valu.modulate.a = min((cos(_timer) / 2.5) + 0.6, 1.0)
	valu.remove_theme_color_override(&"font_color")
	_update_text()

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


func _on_checkbox_toggled(toggled_on: bool) -> void:
	for i in ctrl_buttons:
		i.disabled = !toggled_on


func _on_close_btn_pressed() -> void:
	window.hide()
	Thunder.get_tree().root.grab_focus()


func _on_confirmation_dialog_confirmed() -> void:
	window.grab_focus.call_deferred()
	var path: String
	match stored_reset_type:
		"SavePipes":
			for i in ProfileManager.profiles.keys():
				ProfileManager.delete_profile(i)
			ProfileManager.profiles = {}
			SecretsManager.notify("All save profiles deleted")
		"Achievements":
			path = "user://achievements.thss"
			var err := MobileCompat.remove_user_file(path)
			if err != OK:
				SecretsManager.notify_error("File does not exist")
			else:
				SecretsManager.secrets = {}
				SettingsManager.set_tweak("console_enabled", false)
				if Console.is_visible():
					Console.hide()
				SecretsManager.notify("Achievements have been reset")
		"Tweaks":
			path = "user://tweaks.thss"
			var err := MobileCompat.remove_user_file(path)
			if err != OK:
				SecretsManager.notify_error("File does not exist")
			else:
				await get_tree().physics_frame
				SettingsManager.restart_application.call_deferred(false)
		"Settings":
			path = "user://settings.thss"
			var err := MobileCompat.remove_user_file(path)
			if err != OK:
				SecretsManager.notify_error("File does not exist")
			else:
				await get_tree().physics_frame
				SettingsManager.restart_application.call_deferred(false)
		"Minix":
			path = "user://minigames.thss"
			var err := MobileCompat.remove_user_file(path)
			if err != OK:
				SecretsManager.notify_error("File does not exist")
			else:
				SecretsManager.notify("Minix scores have been reset")
			
	stored_reset_type = ""


func _on_confirmation_dialog_canceled() -> void:
	confirmation_dialog.hide()
	window.grab_focus()
	stored_reset_type = ""
