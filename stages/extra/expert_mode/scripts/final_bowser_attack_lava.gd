extends BowserAttack

## Bowser's hammer attack

@export var wait_time: float = 1.5
@export_group("Movement")
@export var lock_movement: bool = true
@export var lock_direction: bool = false
@export_group("Animations")
## Animation name string for preparing to fire
@export var animation_pre: String = "throw_pre"
@export var sprite_offset_x: float = 7

@onready var lava_bowser: Node2D = $"../../LavaBowser/LavaBowser"
#@onready var lava_children: Array[Sprite2D]
@onready var light_effect_lava: Node2D = $"../../LavaBowser/LightEffectLava"

const CRUSH_2 = preload("res://sfx/IntroCastleCrush2.wav")

func _ready() -> void:
	var lava_base = lava_bowser.get_child(0)
	#lava_children.resize(21)
	#lava_children[0] = lava_base
	for i in 20:
		var more_lava = lava_base.duplicate()
		more_lava.position.x = 32 * (i + 1)
		lava_bowser.add_child(more_lava)
		#lava_children[i + 1] = more_lava
		
		if i % 3 == 0:
			var more_light = light_effect_lava.duplicate()
			more_lava.add_child(more_light)

func start_attack() -> void:
	super()
	middle_attack()


func middle_attack() -> void:
	super()
	
	# Tween for processing attack
	#var tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
	#tween.tween_interval(0.3)
	Audio.play_1d_sound(CRUSH_2, false)
	Thunder._current_camera.shock_smooth(8, 16)
	await get_tree().create_timer(1.0, false).timeout
	lava_bowser.lava_attack()
	
	await get_tree().create_timer(8.0, false).timeout
	end_attack()
	#tween.tween_property(platf, "position:y", 48, 1.0).set_ease(Tween.EASE_IN)
	#tween.tween_interval(0.3)
	
	# Tween to end the process and restore data
	#tween.tween_callback(end_attack)


func end_attack() -> void:
	#var tween: Tween = create_tween()
	
	#await tween.finished
	super()
