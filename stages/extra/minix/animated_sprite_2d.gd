extends AnimatedSprite2D

const LoopOffsetBehaviorScript = preload("uid://cdwp13k80fepv")

var loop_offset_behavior_script: GDScript

func fade_out(duration: float = 0.5) -> void:
	var tw = create_tween()
	tw.tween_property(self, "self_modulate:a", 0.0, duration)


func _ready() -> void:
	var _suit = CharacterManager.get_suit("small", "" if SettingsManager.settings.skin else "Mario")
	sprite_frames = SkinsManager.apply_player_skin(_suit)
	loop_offset_behavior_script = ByNodeScript.activate_script(LoopOffsetBehaviorScript, self, {suit = _suit.name})
	
	play(&"walk")

func _physics_process(delta: float) -> void:
	if animation != "walk":
		play("walk")
