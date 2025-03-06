extends MenuSelection

@onready var parent: Control = get_parent()
@onready var place: Label = $Place
@onready var score: RichTextLabel = $Score
@onready var score_temp: String = score.text
@onready var texture_rect: TextureRect = $TextureRect
@onready var node_2d: Node2D = Scenes.current_scene.get_node(^"START/Node2D")
@onready var lb: Node2D = Scenes.current_scene.get_node(^"START/Leaderboard")

func init_record() -> void:
	place.text = "%s." % int( get_index() + ((lb.page - 1) * 100) )
	last_rect_size = Vector2.ZERO
	size.y = custom_minimum_size.y

func _handle_select(mouse_input: bool = false) -> void:
	if !visible: return
	super(mouse_input)
	if parent.expanded == self:
		parent.expanded = null
	else:
		parent.select(self)


var last_rect_size = Vector2.ZERO
func _process(delta: float) -> void:
	if !parent.visible || !visible: return
	if abs(size.y-custom_minimum_size.y) < 1:
		size.y = custom_minimum_size.y
	
	#resize to target size
	if parent.expanded == self:
		size.y = lerp(size.y, 114.0, 10 * delta)
	elif !is_equal_approx(size.y, 32.0):
		size.y = lerp(size.y, 32.0, 10 * delta)
	
	#update layout
	if last_rect_size != size:
		parent.queue_redraw()
		last_rect_size = size


func set_record(record: Dictionary) -> void:
	var secs: int = record.time
	var mins: int = floori(secs / 60.0)
	secs -= mins * 60
	
	var time_zone_mins: int = Time.get_time_zone_from_system().bias
	var datetime_dict: Dictionary = Time.get_datetime_dict_from_unix_time(
		Time.get_unix_time_from_datetime_string(record.createdAt) + (time_zone_mins * 60)
	)
	var dt_array: PackedStringArray = Time.get_datetime_string_from_datetime_dict(datetime_dict, true).to_upper().split(" ")
	dt_array[0] = "[color=khaki]" + dt_array[0] + "[/color]"
	var map_index: int = node_2d.map_names.find(record.map) + 1
	#print(map_index)
	texture_rect.texture.region.position.x = wrapi(map_index * 33, 0, 165)
	texture_rect.texture.region.position.y = floor(map_index / 5.0) * 33
	
	score.text = score_temp % [
		Thunder.Math.add_delimiter(str(int(record.score))),
		#str(int(record.score)),
		record.user.username.to_upper(),
		record.map.to_upper(),
		record.godlikes,
		mins, secs,
		" ".join(dt_array),
		Time.get_offset_string_from_offset_minutes(time_zone_mins).to_upper() if time_zone_mins != 0 else ""
	]

func set_empty() -> void:
	score.text = "this record is empty!".to_upper()
