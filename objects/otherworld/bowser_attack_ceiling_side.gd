extends BowserAttack

@export var attack_delay: float = 3.0
@export var spike_left: bool = false
@export var spike_right: bool = false
@export var spike_left_pos: float = 304
@export var spike_right_pos: float = -304
@export_group("Animations")
# # Animation name string for preparing to fire
#@export var animation_pre: String = "flame_pre"
# # Animation name string for firing
#@export var animation_after: String = "flame_on"

func start_attack() -> void:
	super()
	if spike_left:
		var ceiling = bowser.get_node("../SpikesSide/Sprite2D")
		ceiling._state = 1
		ceiling.bottom_line_position = spike_left_pos
		ceiling._activation_delay = attack_delay
	if spike_right:
		var ceiling = bowser.get_node("../SpikesSideRight/Sprite2D")
		ceiling._state = 1
		ceiling.bottom_line_position = spike_right_pos
		ceiling._activation_delay = attack_delay
	var tw = create_tween()
	tw.tween_interval(attack_delay)
	tw.tween_callback(middle_attack)


func middle_attack() -> void:
	super()
	end_attack()


func end_attack() -> void:
	super()
	#bowser.sprite.play(animation_after)
