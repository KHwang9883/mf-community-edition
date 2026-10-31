extends "res://engine/singletones/nodes/viewport/debug_player_speed.gd"

## 运行时速通统计：右上角显示玩家的速度、il 帧、坐标等数据。
## 复用 engine 里的统计脚本，但不再依赖启动参数 —— 显示与否由 tweak
## "speedrun_stats" 控制，打开/关闭立即生效，不需要重启游戏。

const TWEAK := &"speedrun_stats"
const BASE_FONT_SIZE := 14


func _ready() -> void:
	# 不调用父类 _ready：它会在没有 --speedrun-stats 时释放自己。
	_hide_builtin_label()
	_apply_layout.call_deferred()
	_refresh_visibility()
	SettingsManager.tweaks_updated.connect(_refresh_visibility)
	get_window().size_changed.connect(_apply_layout)


func _physics_process(delta: float) -> void:
	if !visible:
		return
	super(delta)


func _refresh_visibility() -> void:
	visible = bool(SettingsManager.get_tweak(TWEAK, false))


## 与引擎自带的 PlayerSpeed 保持同一位置/字号；触屏设备按界面缩放比例放大，
## 并避开右上角的屏幕暂停键。
func _apply_layout() -> void:
	var scale := MobileCompat.popup_scale() if MobileCompat.is_touch_device() else 1.0
	var right := 3.0 * scale
	if MobileCompat.is_touch_device() && is_instance_valid(TouchControls.pause_btn):
		var pause_size: float = TouchControls.pause_btn.size.x
		if pause_size > 0.0:
			right = pause_size + 12.0
	anchor_left = 1.0
	anchor_right = 1.0
	offset_left = -right - 26.0 * scale
	offset_top = -1.0 * scale
	offset_right = -right
	offset_bottom = 29.0 * scale
	horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_theme_font_size_override(&"font_size", int(BASE_FONT_SIZE * scale))
	add_theme_constant_override(&"line_spacing", -3)
	add_theme_constant_override(&"outline_size", 1)


## 关掉引擎自带的那份（它只在带启动参数时存在），避免和这份重复。
func _hide_builtin_label() -> void:
	var builtin := get_tree().root.get_node_or_null(
		^"GlobalViewport/PlayerSpeed"
	)
	if builtin == null:
		return
	builtin.visible = false
	builtin.process_mode = Node.PROCESS_MODE_DISABLED
