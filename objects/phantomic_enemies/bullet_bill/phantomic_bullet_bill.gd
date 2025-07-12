extends GeneralMovementBody2D

@export_category("Phantomic Bullet Bill")
@export var acceleration: float = 500
@export var rotation_ratio: float = 0.01
@export_range(0, 180, 0.001, "suffix:°") var view_angle: float = 75

var rota: float
var is_ready: bool
var accelerating: bool

var tween: Tween

var _modulate: Color

@onready var speed_init: Vector2 = speed
@onready var particles: GPUParticles2D = $Sprite/Particles


func _ready() -> void:
	await get_tree().create_timer(0.01, false, true).timeout
	
	super()
	
	is_ready = true
	if sprite_node:
		rota = sprite_node.global_rotation if dir > 0 else sprite_node.global_rotation + PI


func _physics_process(delta: float) -> void:
	if !is_ready: return
	
	super(delta)
	
	var player: Player = Thunder._current_player
	if !player: return
	
	if sprite_node:
		var look_at_pos: float = global_position.direction_to(player.global_position).dot(velocity.normalized())
		var view: float = cos(deg_to_rad(view_angle))
		
		if look_at_pos > view:
			rota = lerp_angle(rota, global_position.direction_to(player.global_position).angle(), rotation_ratio)
		if accelerating:
			speed_init += speed_init.normalized() * acceleration * delta
		rota = wrapf(rota, -PI, PI)
		speed = speed_init.rotated(rota)
		
		sprite_node.global_rotation = rota
		if sprite_node.rotation > PI/2 || sprite_node.rotation < -PI/2:
			sprite_node.rotation += PI


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	particles.reparent.call_deferred(get_parent())
	await get_tree().create_timer(2, false, true).timeout
	particles.queue_free()
