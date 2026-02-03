extends GeneralMovementBody2D

const STOMP = preload("res://engine/objects/enemies/_sounds/stomp.wav")
const STOMP_HAT = preload("res://objects/human_lab_2/hat_clone/sfx/stomp.wav")

@export var stomping_creation: InstanceNode2D
@export var lying_time_sec: float = 3.0

@onready var enemy_attacked: Node = $Body/EnemyAttacked
@onready var original_stomp = enemy_attacked.stomping_sound
@onready var active_nogi: AnimatedSprite2D = $Sprite/ActiveNOGI
@onready var collision_body: CollisionShape2D = $Body/Collision
@onready var collision_body_2: CollisionShape2D = $Body/Collision2

var prev_speed: float
var is_lying: bool


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
	Audio.play_sound(STOMP_HAT, self, false)
	sprite_node.play("lying")
	active_nogi.stop()
	active_nogi.visible = false
	
	turn_sprite = false
	prev_speed = speed.x
	speed.x = 0
	collision_body.disabled = true
	collision_body_2.disabled = false
	get_tree().create_timer(lying_time_sec, false).timeout.connect(get_up)


func get_up() -> void:
	sprite_node.play("standup")
	
	await sprite_node.animation_finished
	is_lying = false
	enemy_attacked.stomping_sound = original_stomp
	sprite_node.play("default")
	active_nogi.play()
	active_nogi.visible = true
	
	turn_sprite = true
	speed.x = prev_speed
	prev_speed = 0
	collision_body.disabled = false
	collision_body_2.disabled = true
