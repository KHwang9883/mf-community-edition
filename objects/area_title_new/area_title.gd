extends CanvasLayer

@onready var title: Label = $Frame/Title
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func display(section: Control) -> void:
	if !is_instance_valid(section):
		return
	
	title.text = section.name.capitalize().to_upper()
	
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play(&"appear")
