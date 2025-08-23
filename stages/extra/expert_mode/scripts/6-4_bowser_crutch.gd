extends Node2D

@onready var static_body_2d: StaticBody2D = $"../StaticBody2D"
var changed: bool
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var block: AnimatableBody2D = $"../Path2D2/PlatformPathGray/Block"
@onready var platform_path_gray: PathFollow2D = $"../Path2D2/PlatformPathGray"

func _on_bowser_health_changed(to: int) -> void:
	if changed: return
	if to <= 0:
		changed = true
		static_body_2d.collision_layer = 16 + 32 + 64
		var tw = create_tween().set_parallel()
		tw.tween_property(sprite_2d, "modulate:a", 1.0, 0.5)
		tw.tween_property(platform_path_gray, "modulate:a", 0.0, 0.5)
		block.collision_layer = 0
