extends MenuSelection

@onready var parent: Control = get_parent()
@onready var place: Label = $Place
@onready var username: Label = $Username
@onready var score: Label = $Score
@onready var godlikes: Label = $Godlikes
@onready var godlikes_temp: String = godlikes.text
@onready var time: Label = $Time
@onready var time_temp: String = time.text
@onready var date: Label = $Date
@onready var date_temp: String = date.text


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
		size.y = lerp(size.y, 128.0, 10 * delta)
	else:
		size.y = lerp(size.y, custom_minimum_size.y, 10 * delta)
	
	#update layout
	if last_rect_size != size:
		parent.queue_redraw()
		last_rect_size = size


func set_record(record: Dictionary) -> void:
	username.text = record.user.username
	score.text = str(record.score)
	godlikes.text = godlikes_temp % [record.godlikes]
	
	var secs: int = record.time
	var mins: int
	while secs >= 60:
		secs -= 60
		mins += 1
	time.text = time_temp % [mins, secs]
	
	date.text = date_temp % [
		Time.get_datetime_string_from_datetime_dict(
			Time.get_datetime_dict_from_unix_time(
				Time.get_unix_time_from_datetime_string(record.createdAt)
			), true
		)
	]

func set_empty() -> void:
	username.text = "empty"
	score.text = ""
	godlikes.text = ""
	time.text = ""
	date.text = "this record is empty!"
