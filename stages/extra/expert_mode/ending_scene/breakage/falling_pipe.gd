extends GeneralMovementBody2D

signal stun

@export_group("Basic")
@export var trigger_area: Rect2 = Rect2(Vector2(-32, -32), Vector2(64, 480))
@export var stunning_sound: AudioStream
@export var explosion_effect: PackedScene = preload("res://engine/objects/effects/explosion/explosion.tscn")

const STUN = preload("res://engine/objects/projectiles/sounds/stun.wav")

var _step: int
var _vel: Vector2
var _origin: Vector2
var _stunspot: Vector2

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var body: Area2D = $Body
@onready var cover: Sprite2D = $Sprite2D/cover

func _physics_process(delta: float) -> void:
	match _step:
		# Waiting
		0:
			var player: Player = Thunder._current_player
			if !player: return
			var ppos: Vector2 = global_transform.affine_inverse() * player.global_position
			if trigger_area.has_point(ppos):
				_origin = global_position
				_step = 1
				cover.visible = false
				var _sfx = CharacterManager.get_sound_replace(STUN, STUN, "stun", false)
				Audio.play_sound(_sfx, self)
			if player:
				if body.overlaps_body(player):
					player.die()
		# Stunning
		1:
			var player: Player = Thunder._current_player
			_vel = velocity.normalized()
			motion_process(delta)
			if player:
				if body.overlaps_body(player):
					player.die()
			
			if is_on_floor():
				# Stops if stunning on the ground
				_step = 2
				_stun()
				_stunspot = global_position
		2:
			#set_deferred(&"collision_layer", 0b1110000)
			#set_deferred(&"collision_mask", 0b1)
			#var shape = collision_shape.shape.duplicate(true)
			#shape.size.x = 32
			#collision_shape.shape = shape
			_step = 3
			

func _stun() -> void:
	stun.emit()
	Audio.play_sound(stunning_sound, self)
	_explosion()


func _explosion() -> void:
	var expl = explosion_effect.instantiate()
	Scenes.current_scene.add_child(expl)
	expl.global_transform = global_transform
	expl.position.y += 48
	expl.reset_physics_interpolation()
		
