extends "res://engine/objects/bosses/bowser/bowser.gd"

const ZORRO_HUD = preload("res://objects/human_lab_2/zorro/zorro_hud.tscn")

func _ready() -> void:
	if instakill_from_lava:
		$Body.add_to_group(&"#lava_body")
	sprite.animation_looped.connect(_on_sprite_animation_looped)
	_speed = speed.x
	facing = get_facing(facing)
	direction = facing
	vel_set_x(0)
	#enemy_attacked.killing_immune = {}
	if tweaked_stomping:
		enemy_attacked.stomping_player_jumping_max = enemy_attacked.stomping_player_jumping_min
	
	# HUD
	hud = ZORRO_HUD.instantiate()
	hud.bowser = self
	hud.y_offset = y_offset
	health_changed.connect(hud.life_changed)
	add_sibling.call_deferred(hud)

func _physics_process(delta: float) -> void:
	super(delta)
	sprite.offset.x = 10 * facing

# Bowser's death
func die(corpse_intro: bool = true) -> void:
	$Sprite/ActiveNOGI.free()
	super(corpse_intro)
