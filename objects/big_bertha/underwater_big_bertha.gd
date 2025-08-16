extends GeneralMovementBody2D

const BABY_BERTHA = preload("res://objects/big_bertha/baby_bertha.tscn")

var phase: float
var tw: Tween

@onready var center: Vector2 = position
@onready var area_2d: Area2D = $Area2D
var skips: int = 0
var creating_baby: bool

func _ready() -> void:
	super()
	area_2d.area_entered.connect(_on_area_entered)
	sprite_node.play("default")
	
	dir = 1
	toggle_dir()


func _physics_process(delta: float) -> void:
	position.y = center.y + 8 * sin(phase)
	phase = wrapf(phase + 2.33 * delta, 0, 360)
	sprite_node.speed_scale = max(1.0, abs(speed.x * 0.015))
	
	motion_process(delta, slide)
	if !is_zero_approx(speed.x):
		dir = int(signf(speed.x))
	
	if turn_sprite && is_instance_valid(sprite_node):
		sprite_node.flip_h = dir < 0

func toggle_dir() -> void:
	skips -= 1
	dir = -dir
	if tw: tw.kill()
	tw = create_tween()
	tw.tween_property(self, "speed:x", 180 * dir, 1.1).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "speed:x", 0, 1.0).set_ease(Tween.EASE_IN)
	tw.tween_callback(toggle_dir)
	if !creating_baby && Thunder.rng.get_randi_range(0, 1) == 0 && skips < 0:
		creating_baby = true
		skips = 1
		stop_and_create_baby()

func stop_and_create_baby() -> void:
	await get_tree().create_timer(0.2, false, true).timeout
	if tw: tw.kill()
	speed.x = 0
	sprite_node.play("jump")
	await get_tree().create_timer(0.8, false, true).timeout
	
	var baby = BABY_BERTHA.instantiate()
	baby.is_spawned = true
	baby.speed.x = 350 * dir
	baby.life_time = 5
	baby.add_to_group(str(get_instance_id()))
	baby.transform = transform
	add_sibling(baby)
	Thunder.reorder_on_top_of(self, baby)
	var _t = baby.create_tween()
	_t.tween_property(baby, "speed:x", 50 * dir, 0.6)
	
	if tw: tw.kill()
	tw = create_tween()
	tw.tween_property(self, "speed:x", 180 * dir, 1.0).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "speed:x", 0, 1.0).set_ease(Tween.EASE_IN)
	tw.tween_callback(toggle_dir)
	creating_baby = false

func _on_area_entered(area: Area2D) -> void:
	if !area.is_inside_tree() || !is_instance_valid(area.get_parent()): return
	var body = area.get_parent()
	
	if !body.is_in_group(str(get_instance_id())): return
	if abs(body.speed.x) > 180: return
	
	var left_right: int = -1 if global_position.x < body.global_position.x else 1
	body.turn_sprite = false
	var _btw: Tween = body.create_tween()
	_btw.tween_property(body, "speed:x", 250 * left_right, 0.2)
	skips = 0
	while is_inside_tree() && is_instance_valid(body):
		if is_queued_for_deletion(): return
		if left_right > 0 && body.global_position.x > global_position.x:
			body.queue_free()
			sprite_node.play("default")
		elif left_right < 0 && body.global_position.x < global_position.x:
			body.queue_free()
			sprite_node.play("default")
		await get_tree().physics_frame


func _on_enemy_attacked_killed_succeeded() -> void:
	for node in get_tree().get_nodes_in_group(str(get_instance_id())):
		if !is_instance_valid(node) || node.is_queued_for_deletion(): continue
		if node.turn_sprite == true: continue
		node.turn_sprite = true
		var _dir: int = signi(node.speed.x)
		var _btw = node.create_tween()
		_btw.tween_property(node, "speed:x", 50 * _dir, 0.4).set_ease(Tween.EASE_OUT)
