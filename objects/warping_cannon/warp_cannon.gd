extends Area2D

const EXPLOSION: PackedScene = preload("res://engine/objects/effects/explosion/explosion.tscn")

@export_category("Warping Cannon")
@export var rotation_speed: float = 50
@export var rotation_limit: Vector2
@export var cannon_shootng_speed: float = 1000
@export var cannon_moving_sound: AudioStream = preload("res://sfx/robot.mp3")
@export var cannon_sound: AudioStream = preload("res://engine/objects/enemies/bullet_bill/bill/sounds/bullet.ogg")

var behaviors: Array[ByNodeScript]

var tween: Tween

var _player_on: bool
var _player_left: bool = true
var _player_z: int
var pressing: bool

@onready var direction: Sprite2D = $Direction
@onready var direction_pos: Vector2 = direction.position


func _physics_process(delta: float) -> void:
	var player: Player = Thunder._current_player
	if !player: return
	
	player = player as Player
	if !_player_on && overlaps_body(player) && _player_left:
		_player_on = true
		_player_left = false
		behaviors.append(player._animation_behavior)
		behaviors.append(player._physics_behavior)
		behaviors.append(player._suit_behavior)
		behaviors.append(player._extra_behavior)
		
		player.global_position = global_position
		player._animation_behavior = null
		player._physics_behavior = null
		player._suit_behavior = null
		player._extra_behavior = null
		_player_z = player.sprite_container.z_index
		player.sprite_container.z_index = -10
		player.visible = false
		player.warp = Player.Warp.IN
		
		direction.visible = true
		
		tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
		tween.tween_property(direction, "position:y", direction_pos.y - cannon_shootng_speed / 20, 1)
		tween.tween_property(direction, "position:y", direction_pos.y, 1)
	
	if _player_on:
		player.control_process()
		if player.left_right < 0:
			rotate(deg_to_rad(-rotation_speed * delta))
		elif player.left_right > 0:
			rotate(deg_to_rad(rotation_speed * delta))
		if player.left_right != 0 && !pressing:
			pressing = true
			Audio.play_sound(cannon_moving_sound, self)
		elif player.left_right == 0:
			pressing = false
		
		if player.jumped:
			Audio.play_sound(cannon_sound, self)
			NodeCreator.prepare_2d(EXPLOSION, self).bind_global_transform(Vector2.UP * 48, 0).create_2d().call_method(
				func(eff: Node2D) -> void:
					eff.z_index = 1
					eff.scale *= 2.4
			)
			
			_player_on = false
			player._animation_behavior = behaviors[0]
			player._physics_behavior = behaviors[1]
			player._suit_behavior = behaviors[2]
			player._extra_behavior = behaviors[3]
			player.visible = true
			player.warp = Player.Warp.NONE
			behaviors.clear()
			
			player.vel_set(Vector2.UP.rotated(global_rotation) * cannon_shootng_speed)
			player.direction = signi(int(player.speed.x))
			
			tween.kill()
			tween = null
			direction.position = direction_pos
			direction.visible = false
	
	if !_player_left && !overlaps_body(player):
		player.sprite_container.z_index = _player_z
		_player_z = 0
		_player_left = true
