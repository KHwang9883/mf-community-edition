extends Node

const SELECT_MAIN = preload("res://engine/components/ui/_sounds/select_main.wav")
const SMOKE = preload("res://engine/objects/effects/smoke/smoke.tscn")

var entered: bool

@onready var coin_brick: AnimatableBody2D = $"../../CoinBrick"
@onready var poison_mushroom_wings_4: CharacterBody2D = $"../../PoisonMushroomWings4"

func _on_area_2d_2_player_enter() -> void:
	entered = true
	Audio.play_1d_sound(SELECT_MAIN, false, {volume = -2})
	
	coin_brick.show()
	coin_brick.process_mode = Node.PROCESS_MODE_INHERIT
	var sm = SMOKE.instantiate()
	sm.position = coin_brick.global_position
	Scenes.current_scene.add_child(sm)
	if is_instance_valid(poison_mushroom_wings_4):
		poison_mushroom_wings_4.activate()
		poison_mushroom_wings_4.show()


func _on_pipe_in_5_warp_started() -> void:
	if !entered: return
	if is_instance_valid(poison_mushroom_wings_4):
		poison_mushroom_wings_4.kill_enemy()
