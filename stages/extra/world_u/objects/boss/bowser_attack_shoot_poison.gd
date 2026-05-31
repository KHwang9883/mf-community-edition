extends BowserAttack

@export var projectile_inst: InstanceNode2D = preload("./bowser_attack_shoot_instance.tres")
@export var flame_sound: AudioStream = preload("res://engine/objects/enemies/bullet_bill/bill/sounds/bullet.ogg")
@export var flame_delay: float = 1.15
@export var flame_speed_x: float = 100
@export_group("Animations")
## Animation name string for preparing to fire
@export var animation_pre: String = "flame_pre"
## Animation name string for firing
@export var animation_after: String = "flame_on"

@onready var pos_flame: Marker2D = $"../PosFlame"
var tw: Tween


func start_attack() -> void:
	super()
	bowser.skull.play(animation_pre)
	await get_tree().create_timer(0.3, false, true).timeout
	bowser.skull.play("flame_loop")
	tw = create_tween().set_loops()
	tw.tween_callback(middle_attack)
	tw.tween_interval(flame_delay)


func middle_attack() -> void:
	super()
	if !projectile_inst: return
	Audio.play_sound(flame_sound, bowser, false, {
		pitch = randf_range(1.0, 1.2),
		volume = -6
	})
	NodeCreator.prepare_ins_2d(projectile_inst, bowser).create_2d().call_method(
		func(flm: Node2D) -> void:
			flm.global_position = pos_flame.global_position
			flm.speed.x = flame_speed_x
			flm.speed *= signf(bowser.speed.x)
	)


func end_attack() -> void:
	super()
	if tw: tw.kill()
	tw = null
	bowser.skull.play(animation_after)
