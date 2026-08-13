extends GeneralMovementBody2D

const STOMP = preload("res://engine/objects/enemies/_sounds/stomp.wav")
const STOMP_HAT = preload("res://objects/human_lab_2/ramireys/hat_clone/sfx/stomp.wav")
const KICK = preload("res://engine/objects/players/prefabs/sounds/kick.wav")

@export var stomping_creation: InstanceNode2D
@export var lying_time_sec: float = 2.4

@onready var enemy_attacked: Node = $Body/EnemyAttacked
@onready var original_stomp = enemy_attacked.stomping_sound
@onready var active_nogi: AnimatedSprite2D = $Sprite/ActiveNOGI

@onready var coll: CollisionShape2D = $Collision
@onready var coll_2: CollisionShape2D = $Collision2
@onready var collision_body: CollisionShape2D = $Body/Collision
@onready var collision_body_2: CollisionShape2D = $Body/Collision2
@onready var attack: ShapeCast2D = $Attack
@onready var body: Area2D = $Body

var prev_speed: float
var is_lying: bool
var wake_timer: float

func _ready() -> void:
	super()
	attack.belongs_to = Data.PROJECTILE_BELONGS.PLAYER


func get_stomped() -> void:
	if is_lying:
		var vars: Dictionary = {
			enemy_attacked = enemy_attacked,
		}
		NodeCreator.prepare_ins_2d(stomping_creation, self).execute_instance_script(vars).create_2d()
		Audio.play_sound(STOMP, self, false)
		queue_free.call_deferred()
		return
	is_lying = true
	Thunder._disconnect(collided_wall, turn_x)
	#enemy_attacked.stomping_offset.y = 16
	enemy_attacked.stomping_enabled = false
	Audio.play_sound(STOMP_HAT, self, false)
	sprite_node.play("lying")
	active_nogi.stop()
	active_nogi.visible = false
	
	turn_sprite = false
	prev_speed = speed.x
	gravity_scale = 0.2
	collision_body.disabled = true
	collision_body_2.disabled = false
	coll.disabled = true
	coll_2.disabled = false
	body.turn_back = false
	
	var pl: Player = Thunder._current_player
	if global_position.x > pl.global_position.x:
		speed.x = 150
		sprite_node.flip_h = true
	else:
		speed.x = -150
		sprite_node.flip_h = false
	speed.y = -80


func _physics_process(delta: float) -> void:
	super(delta)
	if is_lying:
		attack.enabled = abs(speed.x) > 5
		wake_timer += delta
		speed.x = move_toward(speed.x, 0.0, delta * 10 * 50)
		var pl: Player = Thunder._current_player
		if wake_timer > 0.16 && pl && body.overlaps_body(pl):
			get_kicked(pl)
		if wake_timer > lying_time_sec && sprite_node.animation == "lying":
			sprite_node.play(&"standup")
		if wake_timer > lying_time_sec + 0.8:
			get_up()


func get_up() -> void:
	is_lying = false
	Thunder._connect(collided_wall, turn_x)
	enemy_attacked.stomping_sound = original_stomp
	sprite_node.play("default")
	active_nogi.play()
	active_nogi.visible = true
	enemy_attacked.stomping_enabled = true
	
	turn_sprite = true
	speed.x = prev_speed
	prev_speed = 0
	gravity_scale = 0.5
	collision_body.disabled = false
	collision_body_2.disabled = true
	coll.disabled = false
	coll_2.disabled = true
	attack.enabled = false
	wake_timer = 0
	body.turn_back = true


func get_kicked(pl: Player) -> void:
	if pl.warp > Player.Warp.NONE: return
	var _custom_sound = CharacterManager.get_sound_replace(KICK, KICK, "kick", true)
	Audio.play_sound(_custom_sound, self)
	pl.ground_kicked.emit()
	wake_timer = 0
	sprite_node.animation = &"lying"
	if global_position.x > pl.global_position.x:
		speed.x += 150
		sprite_node.flip_h = true
	else:
		speed.x -= 150
		sprite_node.flip_h = false
	speed.y = -80
