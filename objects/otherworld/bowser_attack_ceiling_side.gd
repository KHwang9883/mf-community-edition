extends BowserAttack

@export var attack_delay: float = 3.0
@export var active_ceiling_rect: Rect2
@export_group("Animations")
# # Animation name string for preparing to fire
#@export var animation_pre: String = "flame_pre"
# # Animation name string for firing
#@export var animation_after: String = "flame_on"

func start_attack() -> void:
	super()
	var ceiling = bowser.get_node_or_null("../SpikesSide/Sprite2D")
	if !ceiling:
		return end_attack()
	ceiling._state = 1
	var tw = create_tween()
	tw.tween_interval(attack_delay)
	tw.tween_callback(middle_attack)


func middle_attack() -> void:
	super()
	end_attack()


func end_attack() -> void:
	super()
	#bowser.sprite.play(animation_after)
