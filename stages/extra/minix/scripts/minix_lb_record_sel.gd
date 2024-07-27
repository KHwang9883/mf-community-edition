extends MenuSelection

@onready var parent: Control = get_parent()
@onready var place: Label = $Place
@onready var username: Label = $Username
@onready var score: RichTextLabel = $Score
@onready var score_temp: String = score.text

func _ready() -> void:
	place.text = "%s." % (get_index() + 1)


func _handle_select() -> void:
	super()
	if parent.expanded == self:
		parent.expanded = null
	else:
		parent.select(self)


var last_rect_size = Vector2.ZERO
func _process(delta: float) -> void:
	if !parent.visible: return
	if abs(size.y-custom_minimum_size.y) < 1:
		size.y = custom_minimum_size.y
	
	#resize to target size
	if parent.expanded == self:
		size.y = lerp(size.y, 120.0, 10 * delta)
	else:
		size.y = lerp(size.y, 56.0, 10 * delta)
	
	#update layout
	if last_rect_size != size:
		parent.queue_redraw()
		last_rect_size = size


func set_record(record: Dictionary) -> void:
	username.text = record.user.username
	
	var secs: int = record.time
	var mins: int = floor(secs / 60.0)
	secs -= mins * 60
	
	var time_zone_mins: int = Time.get_time_zone_from_system().bias
	var datetime_dict: Dictionary = Time.get_datetime_dict_from_unix_time(
		Time.get_unix_time_from_datetime_string(record.createdAt) + (time_zone_mins * 60)
	)
	var dt_array: PackedStringArray = Time.get_datetime_string_from_datetime_dict(datetime_dict, true).to_upper().split(" ")
	dt_array[0] = "[color=khaki]" + dt_array[0] + "[/color]"
	
	score.text = score_temp % [
		record.score, record.map.to_upper(),
		record.godlikes,
		mins, secs,
		" ".join(dt_array),
		Time.get_offset_string_from_offset_minutes(time_zone_mins).to_upper() if time_zone_mins != 0 else ""
	]

func set_empty() -> void:
	username.text = "empty"
	score.text = "this record is empty!"
