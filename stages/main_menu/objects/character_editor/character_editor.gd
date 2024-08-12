extends Control

@onready var menu_button: MenuButton = $MenuButton
@onready var control: Control = $Control


func _ready() -> void:
	menu_button.get_popup().index_pressed.connect(_on_menu_button_index_pressed)


func _on_window_mouse_entered() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_shell_button_pressed() -> void:
	if !DirAccess.dir_exists_absolute(SkinsManager.base_dir):
		DirAccess.make_dir_absolute(SkinsManager.base_dir)
	OS.shell_open(SkinsManager.base_dir)


func _on_window_visibility_changed() -> void:
	pass


func _on_menu_button_index_pressed(index: int) -> void:
	var popup: PopupMenu = menu_button.get_popup()
	for i in popup.item_count:
		popup.set_item_checked(i, i == index)
	#popup.set_item_checked(id, true)
	control.visible = index == popup.item_count - 1
		
