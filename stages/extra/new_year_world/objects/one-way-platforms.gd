extends StaticBody2D

@export var correction_on_player_falling: bool = true

@onready var init_collision_margin = get_shape_owner_one_way_collision_margin(0)


var _is_player_falling: bool
func _draw() -> void:
	if !Console.cv.platform_collision_shown: return
	
	for i in get_shape_owners():
		var _the_rect: Rect2 = shape_owner_get_shape(i, 0).get_rect()
		if !_is_player_falling:
			_the_rect.size.y = init_collision_margin
		draw_set_transform_matrix(shape_owner_get_transform(i))
		draw_rect(_the_rect, Color(Color.ORANGE, 0.6), true)

func _physics_process(_delta: float) -> void:
	if !correction_on_player_falling: return
	var player = Thunder._current_player
	if !player: return
	_is_player_falling = player.speed.y >= -5
	if _is_player_falling:
		for i in get_shape_owners():
			shape_owner_set_one_way_collision_margin(
					i, shape_owner_get_shape(i, 0).get_rect().size.y
			)
	else:
		for i in get_shape_owners():
			shape_owner_set_one_way_collision_margin(i, init_collision_margin)
	if Console.cv.platform_collision_shown:
		queue_redraw()
	
