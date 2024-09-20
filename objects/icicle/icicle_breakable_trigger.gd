extends Area2D

const Icicle := preload("icicle_breakable.tscn")

@export_enum("Left:-1", "Right:1") var icicle_creation_moving_direction: int = 1
@export_range(0, 256, 0.1, "or_greater", "suffix:px") var icicle_width: float = 32
@export_range(0, 5, 0.01, "or_greater", "suffix:s") var icicle_creation_interval: float = 0.25
@export_group("Sound", "sound_")
@export var sound_ice_generation: AudioStream = preload("res://engine/objects/players/prefabs/sounds/kick.wav")

@onready var ray: RayCast2D = $RayCast2D


func _ready() -> void:
	body_shape_entered.connect(_on_triggered)


func _on_triggered(_body_rid: RID, body: Node2D, _body_shape_index: int, local_shape_index: int) -> void:
	if body != Thunder._current_player:
		return
	
	var shape_size := (shape_owner_get_shape(shape_find_owner(local_shape_index), local_shape_index) as RectangleShape2D).size
	ray.global_position = (shape_owner_get_owner(shape_find_owner(local_shape_index)) as CollisionShape2D).global_position + \
		Vector2(-icicle_creation_moving_direction * ((shape_size.x - icicle_width) / 2), shape_size.y / 2).rotated(global_rotation)
	ray.force_raycast_update()
	
	while ray.is_colliding():
		Audio.play_sound(sound_ice_generation, self, false)
		
		var icicle := Icicle.instantiate()
		icicle.global_position = ray.global_position
		icicle.global_rotation = global_rotation - PI
		add_sibling.call_deferred(icicle)
		
		ray.translate(Vector2.RIGHT * icicle_creation_moving_direction * icicle_width)
		ray.force_update_transform()
		ray.force_raycast_update()
		
		await get_tree().create_timer(icicle_creation_interval, false).timeout
