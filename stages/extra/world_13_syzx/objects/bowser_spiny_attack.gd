extends BowserAttack

const LAKITU_MEK = preload("res://engine/objects/enemies/lakitus/sounds/lakitu_mek.ogg")
const LAKITU_MYU = preload("res://engine/objects/enemies/lakitus/sounds/lakitu_myu.ogg")
const LAKITU_REK = preload("res://engine/objects/enemies/lakitus/sounds/lakitu_rek.ogg")
const LAKITUS = [LAKITU_MEK, LAKITU_MYU, LAKITU_REK]

@export var projectile_inst: InstanceNode2D
@export var flame_sound: AudioStream = preload("res://engine/objects/bosses/bowser/sounds/bowser_flame.wav")
@export var flame_delay: float = 0.88
## The attack will be executed this many times every cycle
@export_range(0.0, 20.0, 1.0) var execute_times_per_attack: int = 10

@onready var pos_flame: Marker2D = $"../PosSpiny"
@onready var pos_flame_x: float = pos_flame.position.x
var _attacking: bool
var _old_facing: int = 0
@onready var egg_sprite: Sprite2D = $"../EggSprite"

func start_attack() -> void:
	super()
	_attacking = true
	var tw = create_tween()
	tw.tween_interval(flame_delay)
	tw.tween_callback(middle_attack)


func _physics_process(delta: float) -> void:
	if _attacking:
		pos_flame.position.x = pos_flame_x * bowser.facing
		egg_sprite.position = pos_flame.position
		if _old_facing != bowser.facing:
			bowser.facing = _old_facing
			egg_sprite.reset_physics_interpolation()
		egg_sprite.show()
		egg_sprite.rotation_degrees += delta * 50 * 22.5


func middle_attack() -> void:
	super()
	_attacking = false
	_old_facing = 0
	egg_sprite.hide()
	if !projectile_inst: return
	for i in 3:
		Audio.play_sound(LAKITUS.pick_random(), bowser, false)
	
	if Thunder._current_player && Thunder._current_player_state:
		var state = Thunder._current_player_state.type
		if state == PlayerSuit.Type.SMALL:
			execute_times_per_attack = 6
		elif state == PlayerSuit.Type.SUPER:
			execute_times_per_attack = 8
		elif Thunder._current_player_state.name == &"boomerang":
			execute_times_per_attack = 16
	
	pos_flame.position.x = pos_flame_x * bowser.facing
	for _j in execute_times_per_attack:
		NodeCreator.prepare_ins_2d(projectile_inst, bowser).create_2d().call_method(
			func(flm: Node2D) -> void:
				flm.global_position = pos_flame.global_position
				flm.speed.y = -300 - Thunder.rng.get_randf_range(0, 200)
				flm.speed.x = Thunder.rng.get_randf_range(-250, 200)
				if flm is Projectile:
					flm.belongs_to = Data.PROJECTILE_BELONGS.ENEMY
		)
	end_attack()


func end_attack() -> void:
	super()
