extends AnimatedSprite2D

func _ready() -> void:
	var _skin = SettingsManager.settings.skin
	if !_skin.is_empty() && _skin in SkinsManager.misc_textures && SkinsManager.misc_textures[_skin].get("selector"):
		sprite_frames = SpriteFrames.new()
		sprite_frames.add_frame(&"default", SkinsManager.misc_textures[_skin].selector)
		return
	sprite_frames = CharacterManager.get_misc_texture("selector", "", false)
