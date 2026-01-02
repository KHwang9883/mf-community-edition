extends Window

@onready var _prev_visible: bool = visible
@export_node_path("Control") var init_focus_path: NodePath
@onready var init_focus = get_node_or_null(init_focus_path)

func _physics_process(delta: float) -> void:
	if _prev_visible != visible:
		if !visible:
			get_tree().paused = false
		else:
			var win_scale = SettingsManager.get_ui_scale(self)
			SettingsManager.scale_window(self, win_scale)
			move_to_center()
			if init_focus is SpinBox:
				init_focus.get_line_edit().select_all_on_focus = true
				init_focus.get_line_edit().grab_focus.call_deferred()
			elif init_focus is Control:
				init_focus.grab_focus.call_deferred()
	_prev_visible = visible
