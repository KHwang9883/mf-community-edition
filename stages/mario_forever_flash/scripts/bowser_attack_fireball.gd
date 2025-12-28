extends BowserAttack

@export var projectile_inst: InstanceNode2D = preload("res://stages/mario_forever_flash/scripts/bowser_fireball.tres")
@export var flame_sound: AudioStream = preload("res://engine/objects/projectiles/sounds/shoot.wav")
@export var flame_delay: float = 0.88
@export var flame_interval: float = 0.12
@export var flame_speed_x: float = 300
## The attack will be executed this many times every cycle
@export_range(0.0, 20.0, 1.0) var execute_times_per_attack: int = 1
@export_group("Animations")
## Animation name string for preparing to fire
@export var animation_pre: String = "flame_pre"
## Animation name string for firing
@export var animation_after: String = "flame_on"

@onready var pos_flame: Marker2D = $"../PosFlame"
@onready var pos_flame_x: float = pos_flame.position.x


func start_attack() -> void:
	super()
	bowser.sprite.play(animation_pre)
	middle_attack()


func middle_attack() -> void:
	super()
	
	var tween_fireball: Tween = create_tween()
	
	tween_fireball.tween_interval(flame_delay)
	
	for i in execute_times_per_attack:
		tween_fireball.tween_callback(
			func() -> void:
				if !projectile_inst: return
				if bowser.sprite.animation != animation_after:
					bowser.sprite.play(animation_after)
				
				Audio.play_sound(flame_sound, bowser, false)
				pos_flame.position.x = pos_flame_x * bowser.facing
				NodeCreator.prepare_ins_2d(projectile_inst, bowser).create_2d().call_method(
					func(flm: Node2D) -> void:
						# flm.to_pos_y = bowser.pos_y_on_floor + 16 - 32
						flm.global_position = pos_flame.global_position
						if flm is Projectile:
							flm.belongs_to = Data.PROJECTILE_BELONGS.ENEMY
							flm.speed.x = flame_speed_x
							flm.speed *= bowser.facing
						)
		).set_delay(flame_interval)
	
	tween_fireball.tween_callback(end_attack)


func end_attack() -> void:
	super()
