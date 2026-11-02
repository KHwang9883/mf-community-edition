extends Node

## Deletes an imported skin pack after the player confirms through the tweaks
## description box, so it reuses the same popup animation, sound and background
## as a regular tweak description. A (ui_accept) deletes, B (ui_cancel) cancels.
##
## The box unpauses and finishes its close animation before this node does the
## actual file removal, so the pack list can be rebuilt in place without having
## to leave and re-enter the menu.

const TWEAK_DESCRIPTION_PATH := "Tweaks/CanvasLayer"
const SKIN_PREVIEW_PATH := "Tweaks/SubViewportContainer/SubViewport/Selector11"

var skin_id := ""
## Index of the row that opened the prompt, used to restore the selector after
## the list is rebuilt.
var row_index := 0
## The "SKIN PACK..." row that owns the pack list, passed in by the skin row.
var list_row: Node


func _ready() -> void:
	var layer := _find_description_layer()
	if layer == null:
		push_error("[SkinDelete] Tweak description layer not found")
		queue_free()
		return
	var desc := "DELETE \"%s\"?\nTHIS CANNOT BE UNDONE." % skin_id.replacen("_", " ")
	layer.call(
		&"show_confirmation", desc, "DELETE SKIN PACK?", "A = DELETE      B = CANCEL",
		_on_result
	)


## The description box lives inside the tweaks menu scene. Prefer the known
## path, then fall back to searching the current scene for the script.
func _find_description_layer() -> Node:
	var cs := Scenes.current_scene
	if cs == null:
		return null
	var layer := cs.get_node_or_null(NodePath(TWEAK_DESCRIPTION_PATH))
	if layer != null && layer.has_method(&"show_confirmation"):
		return layer
	var stack: Array[Node] = [cs]
	while !stack.is_empty():
		var node: Node = stack.pop_back()
		for child in node.get_children():
			stack.append(child)
		if node.has_method(&"show_confirmation"):
			return node
	return null


func _on_result(confirmed: bool) -> void:
	if confirmed:
		_delete_skin_pack()
	queue_free()


func _delete_skin_pack() -> void:
	if !_can_delete():
		SecretsManager.notify_error("Skin folder not found")
		return

	var path := SkinsManager.base_dir.path_join(skin_id)
	_remove_dir_recursive(path)
	if DirAccess.dir_exists_absolute(path):
		SecretsManager.notify_error("Could not delete: %s" % skin_id)
		return

	var was_current: bool = (
		skin_id == SkinsManager.current_skin || skin_id == SettingsManager.settings.skin
	)
	if was_current:
		SettingsManager.settings.skin = ""
		SkinsManager.current_skin = ""
		SettingsManager.save_settings()

	SkinsManager.load_external_textures()
	_refresh_skin_list()
	if was_current:
		_refresh_skin_preview()
	SecretsManager.notify("Skin deleted: %s" % skin_id)
	print("[SkinDelete] Removed '%s'" % path)


func _can_delete() -> bool:
	if skin_id.is_empty() || skin_id == "none":
		return false
	if skin_id.contains("/") || skin_id.contains(".."):
		return false
	return DirAccess.dir_exists_absolute(SkinsManager.base_dir.path_join(skin_id))


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


## Rebuild the pack list through the entry row itself, then re-select the
## neighbour so the menu does not keep pointing at a freed row. This runs once
## the description box has closed and unpaused the tree, so the rebuilt rows
## appear immediately instead of only after re-entering the submenu.
func _refresh_skin_list() -> void:
	if !is_instance_valid(list_row) || !list_row.has_method(&"_on_button_selection_entered"):
		return
	list_row._on_button_selection_entered()
	var submenu: Node = list_row.get(&"move_to")
	if submenu == null:
		return
	var selectors: Array = submenu.get(&"selectors")
	if row_index >= 0 && !selectors.is_empty():
		submenu.call(&"move_selector", clampi(row_index, 0, selectors.size() - 1), true)


## The player preview on the Tweaks page reads the active skin, so it has to be
## repainted when the current pack is the one that was removed.
func _refresh_skin_preview() -> void:
	var cs := Scenes.current_scene
	if cs == null:
		return
	var selector := cs.get_node_or_null(NodePath(SKIN_PREVIEW_PATH))
	if selector == null || selector.get_child_count() == 0:
		return
	var preview := selector.get_child(0)
	if preview.has_method("_set_frames"):
		preview._set_frames()
