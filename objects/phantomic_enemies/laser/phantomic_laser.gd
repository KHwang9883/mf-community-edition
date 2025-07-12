extends Line2D

@export_category("Laser")
@export var to_color: Color = Color(0.95, 0.5, 1)
@export var color_transforming_interval: float = 0.2
@export_group("Laser Rotation Settings")
@export var laser_rotating_ratio: float = 0.01

var color: Color

var to_player: bool

var tween: Tween

@onready var detector: RayCast2D = $Detector
@onready var particles: GPUParticles2D = $Visual/Particles
@onready var visual: Node2D = $Visual


func _ready() -> void:
	color = default_color
	tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "default_color", to_color, color_transforming_interval/2)
	tween.tween_property(self, "default_color", color, color_transforming_interval/2)
	
	particles.emitting = true


func _exit_tree() -> void:
	particles.reparent.call_deferred(get_parent())
	await get_tree().create_timer(1, false, true).timeout
	particles.queue_free()


func _process(delta: float) -> void:
	# To ground
	var view: Transform2D = get_viewport_transform().affine_inverse()
	
	while !detector.is_colliding():
		points[-1] += Vector2.UP
		detector.target_position = points[-1]
		detector.force_raycast_update()
	
	# Hurting player
	if detector.get_collider() == Thunder._current_player:
		Thunder._current_player.hurt()
	
	while detector.is_colliding():
		points[-1] += Vector2.DOWN
		detector.target_position = points[-1]
		detector.force_raycast_update()
	
	visual.position = detector.target_position
	
	# To player
	if to_player:
		var player: Player = Thunder._current_player
		if !player: return
		
		global_rotation = lerp_angle(global_rotation, global_position.angle_to_point(player.global_position) + PI/2, laser_rotating_ratio)
