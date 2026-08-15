extends Node

const CLOUD_SECRET = preload("res://engine/scenes/save_game_room/sounds/cloud_secret.wav")

@onready var pipe_in_3: Area2D = $"../PipeIn3"
@onready var pipe_in_10: Area2D = $"../PipeIn10"
@onready var question_special_2x: AnimatableBody2D = $"../QuestionSpecial2x"
@onready var control_2x: Control = $"../Control2x"
@onready var control_5x: Control = $"../Control5x"
var player: Player
var can_open: bool

func _ready() -> void:
	Data.values.ux_questions = 0
	player = Thunder._current_player
	if !player:
		return
	player.change_suit(CharacterManager.get_suit("small"), false, true)
	player.suit_changed.connect(_on_suit_changed)


func add_question_mark_score() -> void:
	Data.values.ux_questions += 1
	if Data.values.ux_questions == 2:
		if player && player.suit.type > PlayerSuit.Type.SMALL:
			special_2x_open()
		can_open = true
		control_2x.get_node("Label").text = "X"
	elif Data.values.ux_questions == 5:
		pipe_in_10.position.y = 2416
		control_5x.queue_free()


func _on_pipe_in_3_player_warped_to_pipe_out() -> void:
	Thunder.add_lives(1)
	pipe_in_3.position.x += 1000
	Audio.play_1d_sound(CLOUD_SECRET, false, {volume = -6})

func _on_suit_changed(to: PlayerSuit) -> void:
	if !can_open:
		return
	if !to:
		return
	if to.name == "small":
		special_2x_close()
	else:
		special_2x_open()


func special_2x_close() -> void:
	question_special_2x.hide()
	question_special_2x.process_mode = Node.PROCESS_MODE_DISABLED
	control_2x.show()


func special_2x_open() -> void:
	question_special_2x.show()
	question_special_2x.process_mode = Node.PROCESS_MODE_INHERIT
	question_special_2x._triggered = true
	question_special_2x._animated_sprite_2d.animation = &"empty"
	control_2x.hide()
