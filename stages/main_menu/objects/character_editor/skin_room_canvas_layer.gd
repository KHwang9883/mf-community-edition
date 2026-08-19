extends CanvasLayer

@onready var svc: SubViewportContainer = $SVC
@onready var sv: SubViewport = $SVC/SV
@onready var skin_tweaks: MenuItemsController = $"../QuickSkinSettings"

func _ready() -> void:
	if !is_instance_valid(Data.technical_values.get("main_menu_scene")):
		Data.technical_values.erase("main_menu_scene")
	KevinGlobal.activated = false
	hide()

func _physics_process(delta: float) -> void:
	if !is_inside_tree(): return
	if !get_tree().paused:
		if !visible: return
		if sv.get_child_count() == 0:
			print("patching the skin room exit..")
			on_skin_room_exit()


func _on_child_exit(node: Node) -> void:
	if !is_inside_tree(): return
	if is_queued_for_deletion(): return
	(func():
		for i in sv.get_children():
			if is_instance_valid(i) && i is Stage2D && !i.is_queued_for_deletion():
				return
		print(sv.get_children())
		on_skin_room_exit()
	).call_deferred()

func on_skin_room_exit() -> void:
	hide()
	Thunder._disconnect(Scenes.scene_changed, _on_scene_changed)
	skin_tweaks.focused = true
	if "temp_f4_key" in Data.technical_values:
		SettingsManager.set_tweak("f4_keybind", Data.technical_values.temp_f4_key)
		Data.technical_values.erase("temp_f4_key")
	TransitionManager.clear_transition()
	await get_tree().physics_frame
	if !is_inside_tree(): return
	Scenes.custom_scenes.pause.open_blocked = false


func _on_scene_changed(node: Node) -> void:
	if "_skin_test_level" in node:
		return
	var menu = Data.technical_values.get("main_menu_scene")
	if is_instance_valid(menu):
		menu.free()
	Data.technical_values.erase("main_menu_scene")
	if "temp_f4_key" in Data.technical_values:
		SettingsManager.set_tweak("f4_keybind", Data.technical_values.temp_f4_key)
		Data.technical_values.erase("temp_f4_key")
