extends Node2D

const PARTICLE: PackedScene = preload("./arrowing_particle.tscn")
const SOUND: AudioStream = preload("./sfx/arrowing_anchor.wav")

@export_category("Arrowing Anchor")
@export var detection_radius: float = 160
@export var running_radius: float = 192

var player: Player
var particle: Node2D
var to: Vector2
var dir: Vector2

var in_detection: bool
var on_arrowing: bool

var tween: Tween

@onready var animation: AnimationPlayer = $Animation
@onready var arrow: Node2D = $Arrow


func _ready() -> void:
	animation.stop()


func _physics_process(delta: float) -> void:
	if on_arrowing: return
	
	player = Thunder._current_player
	if !player: return
	
	if !in_detection && player.global_position.distance_squared_to(global_position) <= detection_radius ** 2:
		in_detection = true
		arrow.visible = true
		animation.play_backwards(&"animation")
	elif player.global_position.distance_squared_to(global_position) > detection_radius ** 2:
		in_detection = false
		arrow.visible = false
		animation.stop()
	
	if in_detection:
		_detection_ready()
		arrow.global_rotation = global_position.angle_to_point(player.global_position)


func _detection_ready() -> void:
	if !player: return
	if player.warp == Player.Warp.NONE && Input.is_action_just_pressed(player.control.up) && !on_arrowing:
		Audio.play_sound(SOUND, self)
		
		on_arrowing = true
		
		player.visible = false
		player.warp = Player.Warp.OUT
		player.speed = Vector2.ZERO
		
		to = global_position + Vector2.LEFT.rotated(arrow.global_rotation) * running_radius
		dir = player.global_position.direction_to(to)
		
		particle = NodeCreator.prepare_2d(PARTICLE, player).bind_global_transform().create_2d().call_method(
			func(prt: Node2D) -> void:
				prt.global_rotation = arrow.global_rotation + PI
		).get_node()
		
		tween = create_tween().set_parallel()
		tween.tween_property(particle, "global_position", to, 0.25)
		tween.tween_property(player, "global_position", to, 0.25)
		tween.chain().tween_callback(
			func() -> void:
				player.visible = true
				player.global_position = particle.global_position
				player.force_update_transform()
				player.warp = Player.Warp.NONE
				player.speed = dir * 400
				player.direction = sign(player.speed.x)
				
				while player.test_move(player.global_transform, Vector2.ZERO):
					player.global_position -= dir
				
				particle.desparent_particle()
				particle.queue_free()
				particle = null
		)
		tween.chain().chain().tween_interval(0.25)
		tween.chain().chain().chain().tween_callback(
			func() -> void:
				on_arrowing = false
				tween.kill()
				tween = null
		)
