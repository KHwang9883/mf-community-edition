extends Node2D

const LAKITU_MYU = preload("res://engine/objects/enemies/lakitus/sounds/lakitu_myu.ogg")
const CURSOR_EFFECT = preload("res://stages/extra/click_bonus_game/objects/cursor_effect/cursor_effect.tscn")
const DIE = preload("res://stages/extra/click_bonus_game/sfx/die.wav")

var hover_count: int = 0

@onready var timer = $Timer
@onready var gpu_particles_2d = $CanvasLayer/Cursor/GPUParticles2D
@onready var gpu_particles_2d_2 = $CanvasLayer/Cursor/GPUParticles2D2
@onready var area_2d: Area2D = $Area2D
@onready var cursor: Sprite2D = $CanvasLayer/Cursor
@onready var canvas_layer: CanvasLayer = $CanvasLayer

@export var camera_ref: NodePath
@onready var camera: Camera2D = get_node(camera_ref)

## 手指按下后移动超过这个距离就视为划动：只移动光标，不触发点击。
## 单位是游戏视口坐标（640x480），不是屏幕像素。
const DRAG_THRESHOLD := 22.0

## 指针可见圆圈的半径：光标贴图是 32x32 的圆环，取半宽。
## 触屏点击判定以这个"看得到的圆圈"为准。
const CURSOR_RADIUS := 16.0

var _saved_mouse_pos: Vector2
var _last_click_msec: int = -1000
var _pressed := false
var _dragged := false
var _press_pos := Vector2.ZERO


func _ready() -> void:
	timer.timeout.connect(_create_effect)


func _physics_process(_delta: float) -> void:
	area_2d.global_position = _saved_mouse_pos + camera.offset

func _process(delta: float) -> void:
	cursor.global_position = cursor.get_global_mouse_position()


func _input(event) -> void:
	# 触屏设备上 Godot 会把触摸再模拟成鼠标事件，只处理触摸事件本身，
	# 否则一次触摸会被同时当成触摸与鼠标处理。
	if _is_emulated_pointer(event):
		return

	if event is InputEventScreenDrag || event is InputEventMouseMotion:
		var pos := _event_position(event)
		_track_drag(pos)
		_move_cursor_to(pos)
		return

	if !Scenes.current_scene.can_interact:
		return

	if event is InputEventMouseButton && event.button_index == 1:
		# 鼠标没有划动概念：按下即点击。
		if event.is_pressed():
			_begin_press(event.global_position)
			_move_cursor_to(event.global_position)
			_try_click(false)
		else:
			_end_press()
	elif event is InputEventScreenTouch:
		# 手指只有在按下与抬起之间几乎没移动时才算点击，划动只用来移动光标。
		if event.canceled:
			_end_press()
		elif event.pressed:
			_begin_press(event.position)
		else:
			var was_dragged := _dragged
			_end_press()
			if !was_dragged:
				_move_cursor_to(event.position)
				_try_click(true)


## 触摸事件没有 global_position，用 position；两者都在游戏视口坐标系里。
func _event_position(event: InputEvent) -> Vector2:
	if event is InputEventScreenDrag:
		return event.position
	return event.global_position


func _is_emulated_pointer(event: InputEvent) -> bool:
	if event is InputEventMouseButton || event is InputEventMouseMotion:
		return event.device == InputEvent.DEVICE_ID_EMULATION
	return false


## 手指位置即光标位置。按下与划动都实时更新。
func _move_cursor_to(pos: Vector2) -> void:
	_saved_mouse_pos = pos
	area_2d.global_position = _saved_mouse_pos + camera.offset
	cursor.global_position = cursor.get_global_mouse_position()


func _begin_press(pos: Vector2) -> void:
	_pressed = true
	_dragged = false
	_press_pos = pos


func _end_press() -> void:
	_pressed = false
	_dragged = false


func _track_drag(pos: Vector2) -> void:
	if !_pressed || _dragged:
		return
	if pos.distance_to(_press_pos) >= DRAG_THRESHOLD:
		_dragged = true


func _try_click(from_touch: bool) -> void:
	var now := Time.get_ticks_msec()
	if now - _last_click_msec < 80:
		return
	_last_click_msec = now
	_click_check(from_touch)


func _click_check(from_touch: bool) -> void:
	await get_tree().physics_frame
	if !is_inside_tree() || !Scenes.current_scene.can_interact:
		return

	var group_stars = get_tree().get_nodes_in_group(&"bonus_star")
	var hud_find_me_star = get_tree().get_first_node_in_group(&"find_me_star")
	var has_collision: bool
	var has_failed: bool = true
	var hits: Array
	if from_touch:
		# 触屏走几何重合：指针可见圆圈与星星圆相交即命中，不受物理
		# 形状大小限制（星星比指尖小，物理重叠判定几乎点不中）。
		hits = _touch_hit_areas(group_stars, hud_find_me_star)
	else:
		hits = _collect_hit_areas(group_stars, hud_find_me_star)
	for i in hits:
		if group_stars.has(i):
			has_collision = true
			i.activate()
			break
		if hud_find_me_star == i:
			has_failed = false
	if !has_collision:
		gpu_particles_2d.restart()
		Audio.play_1d_sound(DIE)
		if has_failed:
			Scenes.current_scene.tries._try_lost()
	else:
		gpu_particles_2d_2.restart()
		Audio.play_1d_sound(LAKITU_MYU)


## 触屏命中判定：指针圆（圆心为点击位置、半径 CURSOR_RADIUS）与星星圆
## （圆心为星星位置、半径取其碰撞形状按缩放折算）圆心距不超过两半径之和
## 即算命中。坐标基准与鼠标路径的物理查询一致（area_2d.global_position）。
func _touch_hit_areas(group_stars, hud_find_me_star) -> Array:
	var found := []
	var cursor_pos := area_2d.global_position
	for star in group_stars:
		if !is_instance_valid(star):
			continue
		if cursor_pos.distance_to(star.global_position) \
				<= CURSOR_RADIUS + _star_radius(star):
			found.append(star)
	if is_instance_valid(hud_find_me_star) && cursor_pos.distance_to(
			hud_find_me_star.global_position
			) <= CURSOR_RADIUS + _star_radius(hud_find_me_star):
		found.append(hud_find_me_star)
	return found


## 星星碰撞圆的生效半径：形状半径 × 节点缩放（场景里星星按 0.25/0.15 缩放，
## 原始半径 38 只有约 6~9.5 像素）。找不到圆形形状时按 0 处理（只按圆心判定）。
func _star_radius(star: Node2D) -> float:
	var shape_node := star.get_node_or_null(^"CollisionShape2D") as CollisionShape2D
	if shape_node == null:
		return 0.0
	var circle := shape_node.shape as CircleShape2D
	if circle == null:
		return 0.0
	var s := star.global_scale
	return circle.radius * maxf(absf(s.x), absf(s.y))


func _collect_hit_areas(group_stars, hud_find_me_star) -> Array:
	var found := []
	for i in area_2d.get_overlapping_areas():
		if !found.has(i):
			found.append(i)
	var params := PhysicsPointQueryParameters2D.new()
	params.position = area_2d.global_position
	params.collide_with_areas = true
	params.collide_with_bodies = false
	params.collision_mask = area_2d.collision_mask
	for hit in get_world_2d().direct_space_state.intersect_point(params, 32):
		var collider = hit.collider
		if (group_stars.has(collider) || hud_find_me_star == collider) \
				&& !found.has(collider):
			found.append(collider)
	return found


func _create_effect() -> void:
	var eff = CURSOR_EFFECT.instantiate()
	eff.transform = cursor.transform
	canvas_layer.add_child(eff)


func add_hover() -> void:
	hover_count += 1


func remove_hover() -> void:
	hover_count -= 1
