extends GeneralMovementBody2D

@export var self_ignite_after_sec: float = 0.0
@export var wait_for_explosion_for_sec: float = 3.0
@export_group("Miscellaneous")
@export var explosion_node: PackedScene = preload("res://objects/volcano/bob_omb/explosion/explosion.tscn")
@export var explosion_sound: AudioStream = preload("res://engine/objects/enemies/spike_ceiling/sfx/fall.wav")
@export var kicked_sound: AudioStream = preload("res://engine/objects/players/prefabs/sounds/kick.wav")

var ignited: bool = false
@onready var enemy_attacked: Node = $Body/EnemyAttacked
@onready var vis: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D

func _ready() -> void:
	super()
	if abs(self_ignite_after_sec) > 0.0:
		await get_tree().physics_frame
		while !vis.is_on_screen():
			await get_tree().physics_frame
		await get_tree().create_timer(abs(self_ignite_after_sec), false).timeout
		sprite_node.play(&"self_ignite" if !ignited else &"stomp_ignited")
		set_ignited(true, true)
		_initiate_explosion()
	return


func _physics_process(delta: float) -> void:
	if ignited:
		speed.x = lerpf(speed.x, 0.0, 4.0 * delta)
		if abs(speed.x) < 35:
			turn_sprite = false
			speed.x = 0
		else:
			turn_sprite = true
	super(delta)


func set_ignited(to: bool, self_ignition: bool = false) -> void:
	if ignited == to: return
	ignited = to
	if !to: return
	
	enemy_attacked.stomping_enabled = false
	
	if !self_ignition:
		sprite_node.play(&"stomped")
	turn_sprite = false
	speed.x = 0
	
	if abs(self_ignite_after_sec) > 0.0: return
	await get_tree().create_timer(wait_for_explosion_for_sec, false).timeout
	sprite_node.play(&"stomp_ignited")
	_initiate_explosion()


func fired() -> void:
	if ignited: return
	ignited = true
	sprite_node.play(&"self_ignite")
	enemy_attacked.stomping_enabled = false
	turn_sprite = false
	speed.x = 0
	_initiate_explosion()


func _initiate_explosion() -> void:
	await get_tree().create_timer(1.0, false).timeout
	if Thunder.view.is_getting_closer(self, 64):
		Audio.play_sound(explosion_sound, self, false, { ignore_pause = true })
		var cam: PlayerCamera2D = Thunder._current_camera
		if cam && cam.has_method(&"shock_smooth"):
			cam.shock_smooth(5, 5)
		
	var expl = explosion_node.instantiate()
	Scenes.current_scene.add_child(expl)
	expl.global_position = global_position
	expl.reset_physics_interpolation()
	
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if !body is Player || !ignited: return
	if body.warp > Player.Warp.NONE || enemy_attacked.get_stomping_delayer(): return
	Audio.play_sound(kicked_sound, self)
	body.ground_kicked.emit()
	
	enemy_attacked.stomping_delay()
	update_dir()
	speed = Vector2(350 * -dir, 0)
	turn_sprite = true
	
