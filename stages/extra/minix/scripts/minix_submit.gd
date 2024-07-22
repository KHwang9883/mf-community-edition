extends MenuSelection

var is_enabled: bool = true
@onready var please_type: Node2D = $"../../PleaseType"
@onready var line_edit: LineEdit = $"../../PleaseType/LineEdit"
@onready var enter_to_preview: Label = $"../../PleaseType/EnterToPreview"
@onready var minix_controls: MenuItemsController = $".."

func _handle_select() -> void:
	if !is_enabled:
		Audio.play_1d_sound(preload("res://stages/extra/minix/status/minix_coin_time.wav"))
		return
	super()
	minix_controls.focused = false
	please_type.visible = true
	line_edit.grab_focus()
	line_edit.focus_exited.connect(_on_line_edit_focus_exited, CONNECT_ONE_SHOT)

func _physics_process(delta: float) -> void:
	super(delta)
	if !focused: return
	
	if please_type.visible:
		if Input.is_action_just_pressed("ui_cancel"):
			_on_line_edit_focus_exited()
			Thunder._disconnect(line_edit.focus_exited, _on_line_edit_focus_exited)
			
		var can_submit: bool = false
		if len(line_edit.text) > 2 && line_edit.text.is_valid_identifier():
			can_submit = true
		
		enter_to_preview.visible = can_submit
		
		if can_submit && Input.is_action_just_pressed("ui_accept"):
			Audio.play_1d_sound(selected_sound)
			
			return
			Thunder._disconnect(line_edit.focus_exited, _on_line_edit_focus_exited)
			line_edit.release_focus()


func _on_line_edit_focus_exited() -> void:
	minix_controls.focused = true
	please_type.visible = false
