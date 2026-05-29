extends Node

const CLOUD_SECRET = preload("res://engine/scenes/save_game_room/sounds/cloud_secret.wav")

@onready var pipe_in_3: Area2D = $"../PipeIn3"
@onready var pipe_in_10: Area2D = $"../PipeIn10"
@onready var question_special_2x: AnimatableBody2D = $"../QuestionSpecial2x"
@onready var control_2x: Control = $"../Control2x"
@onready var control_5x: Control = $"../Control5x"

func _ready() -> void:
	Data.values.ux_questions = 0
	Thunder._current_player.change_suit(CharacterManager.get_suit("small"), false, true)


func add_question_mark_score() -> void:
	Data.values.ux_questions += 1
	if Data.values.ux_questions == 2:
		question_special_2x.show()
		question_special_2x.process_mode = Node.PROCESS_MODE_INHERIT
		question_special_2x._triggered = true
		question_special_2x._animated_sprite_2d.animation = &"empty"
		control_2x.queue_free()
	elif Data.values.ux_questions == 5:
		pipe_in_10.position.y = 2416
		control_5x.queue_free()


func _on_pipe_in_3_player_warped_to_pipe_out() -> void:
	Thunder.add_lives(1)
	pipe_in_3.position.x += 1000
	Audio.play_1d_sound(CLOUD_SECRET, false, {volume = -6})
