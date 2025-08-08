extends GravityBody2D

@export var texture: Texture2D
var item := MCItem.new()

@onready var _sprite: Node2D = $Sprite
@onready var _texture_rect: TextureRect = $Sprite/TextureRect
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

var timer: float
var wait_time: float = 0.4

func _ready() -> void:
	super()
	timer = 0
	if speed.x == 0:
		vel_set_x(randf_range(-50, 50))
	#vel_set_y(randf_range(-100, -150))
	if texture:
		_texture_rect.texture = texture
	else:
		texture = _texture_rect.texture
	await get_tree().create_timer(wait_time, false, true).timeout
	collision_shape_2d.set_deferred(&"disabled", false)

func _physics_process(delta: float) -> void:
	motion_process(delta)
	
	
	speed.x = lerp(speed.x, 0.0, 2.5 * delta)
	timer += delta
	_sprite.position.y = cos(timer) * 6
	
	if timer > 120:
		queue_free()


func _on_area_2d_player_enter() -> void:
	var gui = Scenes.custom_scenes.get("MinecraftGUI")
	if !is_instance_valid(gui):
		return
	
	var is_full: bool = gui.push_item(item)
	if !is_full:
		queue_free()
