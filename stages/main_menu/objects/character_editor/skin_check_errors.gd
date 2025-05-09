extends MenuSelection

@onready var valu = get_node_or_null(^"Value")
var _timer: float

func _physics_process(delta: float) -> void:
	super(delta)
	if !valu:
		return
	if focused:
		_timer += delta * 10
		valu.modulate.a = min((cos(_timer) / 2.5) + 0.6, 1.0)
	else:
		valu.modulate.a = 0.0

func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	
	
	var errored: PackedStringArray = []
	if SkinsManager.current_skin:
		SkinsManager.custom_sprite_frames[SkinsManager.current_skin] = {}
		for i in CharacterManager.get_suit_names():
			if !SkinsManager.custom_textures.has(SkinsManager.current_skin):
				errored.append(
					"Suit '%s' contains errors." % [i]
				)
			else:
				var _suit: PlayerSuit = CharacterManager.get_suit(i)
				if !_suit: continue
				var spr_frames := SkinsManager.apply_player_skin(_suit, true)
				if spr_frames && spr_frames == _suit.animation_sprites:
					errored.append(
						"Suit '%s' is using default textures." % [i]
					)
		if !errored.is_empty():
			OS.alert("
".join(errored), "Player Skin Load Error")
		
		
	if errored.is_empty():
		OS.alert("No issues found.", "Skins Check")
