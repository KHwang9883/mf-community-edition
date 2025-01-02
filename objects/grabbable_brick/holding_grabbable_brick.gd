extends Node2D

@onready var player: Player = Thunder._current_player
@onready var throwable = preload("res://objects/grabbable_brick/thrown_grabbable_brick.tscn")
@export var effect: PackedScene = preload("res://engine/objects/effects/smoke/smoke.tscn")
@export var custom_throw_sound: AudioStream = preload("res://engine/objects/players/prefabs/sounds/kick.wav")

var sprite: NodePath
var result: PackedScene
var following: bool
var data: Dictionary = {}

var _following_pos: Vector2 = Vector2(14, -2)
var prev_direction: int
@onready var timer: Timer = $Timer # Timer
var tw: Tween

var is_from_enemy: bool = false

func _ready() -> void:
	if !is_from_enemy:
		var small: bool = player.suit && player.suit.type == player.suit.Type.SMALL
		_following_pos.y = -2 if small else -8
	tw = get_tree().create_tween()
	tw.tween_property(self, "position:y", _following_pos.y, 0.2)
	tw.tween_callback(
		func(): following = true
	)

func _physics_process(delta: float) -> void:
	if is_from_enemy: return
	position.x = _following_pos.x * player.direction
	prev_direction = player.direction
	
	if !following: return
	z_index = 1
	position.y = -2
	if &"holding" in player.suit.extra_vars && !player.suit.extra_vars.is_holding:
		player.suit.extra_vars.holding = self
		player.suit.extra_vars.is_holding = true
	if player.suit && player.suit.type != player.suit.Type.SMALL:
		position.y = -8


func got_thrown(on_death: bool) -> void:
	var res
	res = throwable.instantiate()
	
	if !res: return
	(func():
		Scenes.current_scene.add_child(res)
		res.result = load(scene_file_path)
		res.global_transform = global_transform
		for i in get_groups():
			res.add_to_group(i)
		var _sp: float
		if !on_death:
			if player.up_down == -1 && player.left_right == 0:
				_sp = 0
				res.vel_set_y(-700)
			else:
				_sp = 400 * player.direction
				res.vel_set_y(-500 * int(player.up_down == -1))
			res.vel_set_x(_sp)
			res.constant_speed = _sp
		else:
			following = true
			if tw: tw.kill()
			_sp = 400 * prev_direction
			res.vel_set_x(_sp)
			res.constant_speed = _sp
			res.vel_set_y(-50)
		queue_free()
	).call_deferred()


func _on_timer_timeout() -> void:
	player.suit.extra_vars.is_holding = false
	var ef = effect.instantiate()
	Scenes.current_scene.add_child(ef)
	ef.global_transform = global_transform
	queue_free()
