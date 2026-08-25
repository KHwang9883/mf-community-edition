extends Node

const VALID_MARKERS: PackedStringArray = ["selector.png", "skin_settings.tres"]
const DIR_CANDIDATES: PackedStringArray = [
	"/storage/emulated/0/Download",
	"/storage/emulated/0",
]
const TWEAKS_TITLE := preload("res://engine/fonts/font_variations/tweaks_font_title.tres")
const TWEAKS_VAR := preload("res://engine/fonts/font_variations/tweaks_font_var.tres")

const COLOR_TEXT := Color(1, 1, 0.792157, 1)
const COLOR_OUTLINE := Color(0, 0, 0.329412, 1)
const COLOR_SHADOW := Color(0, 0, 0, 0.435294)

var _dialog: FileDialog
var _progress_layer: CanvasLayer
var _progress_count: Label


static func open_importer(host: Node) -> void:
	var importer: Node = load("res://components/mobile/skin_importer.gd").new()
	host.add_child(importer)
	importer._open.call_deferred()


func _open() -> void:
	_dialog = FileDialog.new()
	_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_dialog.filters = PackedStringArray(["*.zip ; Skin archive"])
	_dialog.title = "Import skin package"
	_dialog.current_dir = _pick_start_dir()
	_dialog.size = Vector2i(
		maxi(int(get_window().size.x * 0.8), 520),
		maxi(int(get_window().size.y * 0.7), 380)
	)
	_dialog.file_selected.connect(_on_file_selected)
	_dialog.canceled.connect(_cleanup)
	add_child(_dialog)
	MobileCompat.scale_popup_window(_dialog)
	TouchControls.refresh_popup_cache()
	_dialog.popup_centered()


func _pick_start_dir() -> String:
	for candidate in DIR_CANDIDATES:
		if DirAccess.dir_exists_absolute(candidate):
			return candidate
	return ProjectSettings.globalize_path(SkinsManager.base_dir)


func _on_file_selected(zip_path: String) -> void:
	if _dialog:
		_dialog.hide()
	_import_async(zip_path)


const JUNK_FOLDERS: Array[String] = ["__MACOSX"]
const JUNK_FILES: Array[String] = [".DS_Store"]


func _build_import_manifest(files: PackedStringArray) -> Array:
	var normalized: Array = []
	for entry in files:
		var e := entry.replace("\\", "/")
		if e.begins_with("/") || e.contains(".."):
			continue
		if e.is_empty() || e.ends_with("/"):
			continue
		var junk := false
		for folder in JUNK_FOLDERS:
			if e.begins_with(folder + "/"):
				junk = true
				break
		if JUNK_FILES.has(e.get_file()):
			junk = true
		if !junk:
			normalized.append(e)
	if normalized.is_empty():
		return []

	var folder_counts := {}
	for entry in normalized:
		var slash: int = entry.find("/")
		if slash > 0:
			var top: String = entry.substr(0, slash)
			folder_counts[top] = int(folder_counts.get(top, 0)) + 1

	var root_folder := ""
	if folder_counts.size() == 1:
		root_folder = folder_counts.keys()[0] + "/"
	elif folder_counts.size() > 1:
		var real := (folder_counts.keys() as Array).filter(
			func(k): return not (k in JUNK_FOLDERS)
		)
		if real.size() == 1:
			root_folder = real[0] + "/"

	var manifest: Array = []
	for entry in normalized:
		var relative: String = (
			entry.substr(root_folder.length()) if root_folder != "" else entry
		)
		if relative.is_empty():
			continue
		manifest.append([entry, relative])
	return manifest


func _import_async(zip_path: String) -> void:
	TouchControls.begin_import_block()
	_begin_progress()
	var reader := ZIPReader.new()
	var err := reader.open(zip_path)
	if err != OK:
		_finish_import("Cannot open archive (error %d)" % err)
		return

	var files := reader.get_files()
	var manifest := _build_import_manifest(files)
	if manifest.is_empty():
		_finish_import("Not a MFCE skin package\n(missing selector.png / skin_settings.tres)")
		return

	var valid := false
	for pair in manifest:
		var rel: String = pair[1]
		if rel == "selector.png" || rel.ends_with("skin_settings.tres"):
			valid = true
			break
	if !valid:
		_finish_import("Not a MFCE skin package\n(missing selector.png / skin_settings.tres)")
		return

	var skin_name := _derive_skin_name(zip_path)
	var dest := SkinsManager.base_dir.path_join(skin_name)
	if DirAccess.dir_exists_absolute(dest):
		dest += "_%d" % (Time.get_unix_time_from_system() as int % 100000)

	var imported := 0
	for pair in manifest:
		var entry: String = pair[0]
		var relative: String = pair[1]
		var out_path := dest.path_join(relative)
		var parent := out_path.get_base_dir()
		if !DirAccess.dir_exists_absolute(parent):
			DirAccess.make_dir_recursive_absolute(parent)
		var data: PackedByteArray = reader.read_file(entry)
		var file := FileAccess.open(out_path, FileAccess.WRITE)
		if file == null:
			reader.close()
			_finish_import("Failed to write: %s" % relative)
			return
		file.store_buffer(data)
		file.close()
		imported += 1
		if imported % 8 == 0:
			_update_progress(imported, manifest.size())
			await get_tree().process_frame
			if !is_inside_tree():
				reader.close()
				TouchControls.end_import_block()
				return

	reader.close()
	print("[SkinImport] extraction done: %d file(s) -> %s" % [imported, dest])

	if imported == 0:
		_remove_dir_recursive(dest)
		_finish_import("Import failed:\nno files extracted")
		return

	DirAccess.make_dir_recursive_absolute(SkinsManager.base_dir)
	print("[SkinImport] reloading skins...")
	SkinsManager.load_external_textures()
	print("[SkinImport] reload done")
	_refresh_skin_list()
	_finish_import("Skin imported:\n%s\n(%d files)" % [skin_name, imported])


func _refresh_skin_list() -> void:
	var cs := Scenes.current_scene
	if cs == null:
		return
	var selector_row := cs.get_node_or_null(
		NodePath("Tweaks/SubViewportContainer/SubViewport/Tweaks/SkinPackSelect")
	)
	if selector_row != null && selector_row.has_method("_on_button_selection_entered"):
		selector_row._on_button_selection_entered()
		print("[SkinImport] skin list refreshed")


func _begin_progress() -> void:
	var s := MobileCompat.popup_scale()
	_progress_layer = CanvasLayer.new()
	_progress_layer.layer = 101
	_progress_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_progress_layer.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_progress_layer.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override(&"separation", 12 * s)
	center.add_child(box)
	box.add_child(_make_progress_label("IMPORTING SKIN...", TWEAKS_TITLE, int(26 * s)))
	_progress_count = _make_progress_label("", TWEAKS_VAR, int(22 * s))
	box.add_child(_progress_count)
	add_child(_progress_layer)


func _make_progress_label(text: String, font: Font, size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.uppercase = true
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_override(&"font", font)
	label.add_theme_font_size_override(&"font_size", size)
	label.add_theme_color_override(&"font_color", COLOR_TEXT)
	label.add_theme_color_override(&"font_shadow_color", COLOR_SHADOW)
	label.add_theme_color_override(&"font_outline_color", COLOR_OUTLINE)
	label.add_theme_constant_override(&"line_spacing", 1)
	label.add_theme_constant_override(&"shadow_offset_x", 3)
	label.add_theme_constant_override(&"shadow_offset_y", 3)
	label.add_theme_constant_override(&"outline_size", 4)
	return label


func _update_progress(done: int, total: int) -> void:
	if is_instance_valid(_progress_count):
		_progress_count.text = "%d / %d" % [done, total]


func _finish_import(message: String) -> void:
	if is_instance_valid(_progress_layer):
		_progress_layer.queue_free()
	TouchControls.end_import_block()
	_show_status(message)


func _remove_dir_recursive(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		DirAccess.remove_absolute(path)
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		var full := path.path_join(entry)
		if dir.current_is_dir():
			_remove_dir_recursive(full)
		else:
			DirAccess.remove_absolute(full)
		entry = dir.get_next()
	dir.list_dir_end()
	DirAccess.remove_absolute(path)


func _derive_skin_name(zip_path: String) -> String:
	var base := zip_path.get_file().get_basename()
	var regex := RegEx.new()
	regex.compile("[^A-Za-z0-9_\\-]")
	base = regex.sub(base, "_", true).left(40)
	if base.is_empty():
		base = "imported_skin"
	return base


func _show_status(message: String) -> void:
	var status := AcceptDialog.new()
	status.dialog_text = message
	status.title = "Skin import"
	status.ok_button_text = "OK"
	status.confirmed.connect(_cleanup)
	status.close_requested.connect(_cleanup)
	add_child(status)
	MobileCompat.scale_popup_window(status)
	TouchControls.refresh_popup_cache()
	status.popup_centered()


func _cleanup() -> void:
	queue_free()
