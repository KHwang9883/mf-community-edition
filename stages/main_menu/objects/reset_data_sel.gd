extends MenuSelection

const SAVE_CONFIG_EXT := "thss"
const SAVE_PROFILE_EXT := "ths"
const SAVE_PROFILES_DIR := "saves"
const PICKER_DIR_CANDIDATES: PackedStringArray = [
	"/storage/emulated/0/Download",
	"/storage/emulated/0",
]

@onready var window: Window = $Window
@onready var valu: Label = $Value
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog
@onready var import_confirmation: ConfirmationDialog = $ImportConfirmation
@onready var v_box_container: VBoxContainer = $Window/Control/VBoxContainer/VBoxContainer

var _timer: float
var stored_reset_type: String
var ctrl_buttons: Array[Button]
var _file_dialog: FileDialog
var _pending_import_dir: String


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
	if what == "ImportSave":
		_open_import_dialog()
		return
	if what == "ExportSave":
		_open_export_dialog()
		return
	stored_reset_type = what
	confirmation_dialog.dialog_text = "Really %s?" % [text]
	if what in ["Tweaks", "Settings"]:
		confirmation_dialog.dialog_text += "\nThe game will be restarted."
	_show_confirmation()


func _show_confirmation(dialog: ConfirmationDialog = confirmation_dialog, font_base: int = 0) -> void:
	dialog.show()
	_apply_window_scaling(dialog)
	if font_base > 0:
		_scale_dialog_font(dialog, font_base)
	dialog.move_to_center()
	dialog.grab_focus()


## Android 上窗口已由 MobileCompat 按屏幕尺寸缩放，避免再叠加一次 DPI 缩放。
func _apply_window_scaling(dialog: Window) -> void:
	if MobileCompat.android:
		MobileCompat.scale_popup_window(dialog)
		return
	var win_scale = SettingsManager.get_ui_scale(dialog)
	SettingsManager.scale_window(dialog, win_scale)


## 覆盖弹窗默认字号，[param base_size] 为未缩放时的逻辑字号。
func _scale_dialog_font(dialog: Window, base_size: int) -> void:
	var font_size := base_size
	if MobileCompat.android:
		font_size = int(base_size * MobileCompat.popup_scale())
	var dialog_theme := dialog.theme
	if dialog_theme == null:
		dialog_theme = Theme.new()
	dialog_theme.default_font_size = font_size
	dialog.theme = dialog_theme


func _open_import_dialog() -> void:
	var dialog := _create_file_dialog(FileDialog.FILE_MODE_OPEN_DIR, "Import save data")
	dialog.dir_selected.connect(_on_import_dir_selected)
	dialog.popup_centered()


func _open_export_dialog() -> void:
	var dialog := _create_file_dialog(FileDialog.FILE_MODE_OPEN_DIR, "Export save data")
	dialog.dir_selected.connect(_on_export_dir_selected)
	dialog.popup_centered()


func _create_file_dialog(mode: FileDialog.FileMode, title: String) -> FileDialog:
	_close_file_dialog()
	var dialog := FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = mode
	dialog.title = title
	dialog.current_dir = _pick_start_dir()
	dialog.size = Vector2i(
		maxi(int(get_window().size.x * 0.8), 520),
		maxi(int(get_window().size.y * 0.7), 380)
	)
	dialog.canceled.connect(_on_file_dialog_canceled)
	add_child(dialog)
	MobileCompat.scale_popup_window(dialog)
	TouchControls.refresh_popup_cache()
	_file_dialog = dialog
	return dialog


func _pick_start_dir() -> String:
	for candidate in PICKER_DIR_CANDIDATES:
		if DirAccess.dir_exists_absolute(candidate):
			return candidate
	return OS.get_user_data_dir()


func _close_file_dialog() -> void:
	if is_instance_valid(_file_dialog):
		_file_dialog.hide()
		_file_dialog.queue_free()
		_file_dialog = null
		TouchControls.refresh_popup_cache()


func _on_file_dialog_canceled() -> void:
	_close_file_dialog()
	window.grab_focus.call_deferred()


func _on_import_dir_selected(dir: String) -> void:
	_close_file_dialog()
	_pending_import_dir = dir
	import_confirmation.dialog_text = (
		"Import save data?\n\n"
		+ "All current save data will be overwritten.\nThis cannot be undone."
	)
	_show_confirmation(import_confirmation, 12)


func _on_import_confirmation_confirmed() -> void:
	var src_dir := _pending_import_dir
	_pending_import_dir = ""
	if src_dir.is_empty():
		return
	window.grab_focus.call_deferred()
	_import_save_data(src_dir)


func _on_import_confirmation_canceled() -> void:
	_pending_import_dir = ""
	window.grab_focus()


func _on_export_dir_selected(dir: String) -> void:
	_close_file_dialog()
	_export_save_data(dir.path_join("MFCE Saves"))
	window.grab_focus.call_deferred()


func _list_save_files(dir_path: String, extension: String) -> PackedStringArray:
	var files := PackedStringArray()
	if !DirAccess.dir_exists_absolute(dir_path):
		return files
	for file_name in DirAccess.get_files_at(dir_path):
		if file_name.get_extension() == extension:
			files.append(file_name)
	return files


func _export_save_data(dest_dir: String) -> void:
	# Make sure the profile currently in memory is up to date on disk first.
	ProfileManager.save_current_profile()

	var dir_err := DirAccess.make_dir_recursive_absolute(dest_dir)
	if dir_err != OK:
		SecretsManager.notify_error("Cannot create folder: %s" % dest_dir)
		return

	var root := OS.get_user_data_dir()
	var errors: Array[String] = []
	var exported := _sync_save_files(root, dest_dir, SAVE_CONFIG_EXT, errors)
	exported += _sync_save_files(
		root.path_join(SAVE_PROFILES_DIR),
		dest_dir.path_join(SAVE_PROFILES_DIR),
		SAVE_PROFILE_EXT,
		errors
	)

	if !errors.is_empty():
		SecretsManager.notify_error("Export failed: %s" % ", ".join(PackedStringArray(errors)))
	elif exported == 0:
		SecretsManager.notify_error("No save data to export")
	else:
		print("[Save Data] Exported %d file(s) to %s" % [exported, dest_dir])
		SecretsManager.notify("Exported %d save file(s)" % exported)


func _import_save_data(src_dir: String) -> void:
	var root := OS.get_user_data_dir()
	var src_saves := src_dir.path_join(SAVE_PROFILES_DIR)
	var dst_saves := root.path_join(SAVE_PROFILES_DIR)
	if _list_save_files(src_dir, SAVE_CONFIG_EXT).is_empty() \
			&& _list_save_files(src_saves, SAVE_PROFILE_EXT).is_empty():
		SecretsManager.notify_error("No save data found in the selected folder")
		return

	# Only the categories present in the imported folder are replaced.
	var errors: Array[String] = []
	var imported := _sync_save_files(src_dir, root, SAVE_CONFIG_EXT, errors)
	imported += _sync_save_files(src_saves, dst_saves, SAVE_PROFILE_EXT, errors)

	if !errors.is_empty():
		SecretsManager.notify_error("Import failed: %s" % ", ".join(PackedStringArray(errors)))
		return

	print("[Save Data] Imported %d file(s) from %s" % [imported, src_dir])
	SecretsManager.notify("Save data imported. Restarting...")
	await get_tree().create_timer(1.0).timeout
	SettingsManager.restart_application.call_deferred(false)


## Copies every [param extension] file from [param src_dir] into [param dst_dir],
## removing files of the same extension that no longer exist in the source.
func _sync_save_files(
	src_dir: String, dst_dir: String, extension: String, errors: Array[String]
) -> int:
	var src_files := _list_save_files(src_dir, extension)
	if src_files.is_empty():
		return 0
	if DirAccess.make_dir_recursive_absolute(dst_dir) != OK:
		errors.append(dst_dir)
		return 0
	for file_name in _list_save_files(dst_dir, extension):
		if !src_files.has(file_name):
			DirAccess.remove_absolute(dst_dir.path_join(file_name))
	var copied := 0
	for file_name in src_files:
		if _copy_save_file(src_dir.path_join(file_name), dst_dir.path_join(file_name), errors):
			copied += 1
	return copied


func _copy_save_file(from_path: String, to_path: String, errors: Array[String]) -> bool:
	var err := DirAccess.copy_absolute(from_path, to_path)
	if err != OK:
		errors.append(from_path.get_file())
		return false
	return true

func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	
	window.show()
	_apply_window_scaling(window)
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
