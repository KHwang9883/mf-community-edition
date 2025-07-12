extends Sprite2D

@export var speed: float = 1500
@export var strength: float = 60

var length: float


func _physics_process(delta: float) -> void:
	position.x -= speed * delta
	length += speed * delta
	var halflength: float = texture.get_size().x/2
	if length > halflength:
		position.x += halflength
		length -= halflength
	
	var mario: Player = Thunder._current_player
	if !mario: return
	if !mario.test_move(mario.global_transform,Vector2.LEFT.rotated(mario.global_rotation)) && mario.warp == mario.Warp.NONE && !mario.completed:
		mario.position.x -= strength * delta
