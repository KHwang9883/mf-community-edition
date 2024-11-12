extends Player

func _ready() -> void:
	if !Thunder._current_player_state_path.is_empty():
		suit = load(Thunder._current_player_state_path)
	elif Thunder._current_player_state:
		suit = Thunder._current_player_state
	else:
		var small_suit: PlayerSuit = CharacterManager.get_suit("small")
		Thunder._current_player_state = small_suit
		suit = small_suit

	change_suit(suit, false, true)

	Thunder._current_player = self

	if !is_starman():
		sprite.material.set_shader_parameter(&"mixing", false)
	
