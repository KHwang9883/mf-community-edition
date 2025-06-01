extends BowserAttack

@export var attack_delay: float = 1.0
@export var active_ceiling_rect: Rect2
@export_group("Animations")
# # Animation name string for preparing to fire
#@export var animation_pre: String = "flame_pre"
# # Animation name string for firing
#@export var animation_after: String = "flame_on"

@onready var ceiling: VBoxContainer
var _active: bool
var _waiting_for_end: bool

func start_attack() -> void:
	super()
	ceiling = bowser.get_node_or_null("../SpikeCeiling")
	if !ceiling:
		return end_attack()
	ceiling.activated_area = active_ceiling_rect
	_active = true
	_waiting_for_end = false
	var tw = create_tween()
	tw.tween_callback(set.bind("_active", true))
	tw.tween_interval(attack_delay)
	tw.tween_callback(middle_attack)

func _physics_process(delta: float) -> void:
	if _waiting_for_end:
		if !ceiling || ceiling._state < 2:
			_waiting_for_end = false
			end_attack()
		return
	if !_active || !ceiling: return
	
	ceiling._sine += 50 * delta
	ceiling.global_position.y = ceiling.init_pos.y + sin(ceiling._sine) * (ceiling._sine / 70.0)
	#bowser.sprite.play(animation_pre)


func middle_attack() -> void:
	super()
	if !ceiling: return
	_active = false
	#Audio.play_sound(flame_sound, bowser, false)
	ceiling.global_position.y = ceiling.init_pos.y
	ceiling._state = 2
	ceiling.activated_area = Rect2(0, 0, 0, 0)
	_waiting_for_end = true


func end_attack() -> void:
	super()
	#bowser.sprite.play(animation_after)
