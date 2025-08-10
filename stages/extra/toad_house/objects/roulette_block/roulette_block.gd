extends StaticBumpingBlock

@export var result_array: Array[InstancePowerup] = []
@export var result_fallback: InstancePowerup

@onready var anim: AnimatedSprite2D = $Sprites/AnimatedSprite2D/Anim


func got_bumped(by_player: bool = false) -> void:
	if _triggered: return
	bump(true)

func bump(disable: bool, bump_rotation: float = 0, interrupt: bool = false):
	if _triggered && lock_while_triggered: return
	if !active: return
	
	anim.pause()
	var frame_count: int = anim.sprite_frames.get_frame_count(&"default")
	if result_array.size() < frame_count:
		result_array.resize(frame_count)
	
	var _result := result_array[anim.frame]
	var state := _result.creation_nodepack.get_state()
	if Thunder._current_player_state && result_fallback:
		for i in state.get_node_property_count(0):
			if state.get_node_property_name(0, i) == &"to_suit":
				if Thunder._current_player_state.name == state.get_node_property_value(0, i):
					_result = result_fallback
				break
	
	result = _result
	anim.visible = false
	
	super(disable, bump_rotation, interrupt)
