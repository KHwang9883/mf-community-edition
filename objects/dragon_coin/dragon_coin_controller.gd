extends Control

const SECRET_UNLOCKER = preload("res://components/secrets_manager/secret_unlocker.tscn")
const STAR_COIN_WIDTH: int = 26

@export_group("All Collected Achievement", "achievement_")
@export var achievement_name: String
@export var achievement_progress_by_id: String
@export var achievement_progress_to: int

var unlocker: Node

@onready var star_coin_outline: TextureRect = $Control/StarCoinOutline
@onready var star_coin_filled: TextureRect = $Control/StarCoinOutline/StarCoinFilled

func _init() -> void:
	if Data.values.checkpoint == -1 && !Data.values.get("dragon_coin_life", false):
		Data.values.dragon_coins = 0
		Data.values.dragon_coins_max = 3

func _ready() -> void:
	if !Data.has_user_signal(&"dragon_coin_collected"):
		Data.add_user_signal(&"dragon_coin_collected")
	if !Data.has_user_signal(&"all_dragon_coins_collected"):
		Data.add_user_signal(&"all_dragon_coins_collected")
	
	if Data.values.onetime_blocks:
		Data.values.dragon_coin_life = false
	
	if Data.values.checkpoint == -1 && !Data.values.dragon_coin_life:
		Data.values.dragon_coins = 0
		Data.values.dragon_coins_max = get_tree().get_node_count_in_group(&"dragon_coin")
		Data.values.dragon_coins_array = []
	
	if Data.values.checkpoint != -1 && !Data.values.dragon_coin_life:
		Data.values.dragon_coins = Data.values.dragon_coins_max - len(Data.values.dragon_coins_array)
	
	star_coin_outline.size.x = STAR_COIN_WIDTH * Data.values.dragon_coins_max
	star_coin_filled.size.x = STAR_COIN_WIDTH * Data.values.dragon_coins
	star_coin_filled.visible = Data.values.dragon_coins > 0
	
	Thunder._connect(Data.checkpoint_set, _on_checkpoint_set)
	Thunder._connect(Signal(Data, &"dragon_coin_collected"), _on_collected)
	
	if achievement_name && achievement_progress_to:
		unlocker = SECRET_UNLOCKER.instantiate()
		add_child(unlocker)
		var _secrets: Array[String] = [achievement_name]
		unlocker.secrets = _secrets
		unlocker.progress_by_id = achievement_progress_by_id
		unlocker.progress_to = achievement_progress_to
		Thunder._connect(Signal(Data, &"all_dragon_coins_collected"), _on_all_collected)


func _on_checkpoint_set() -> void:
	Data.values.dragon_coins_array = []
	for i in get_tree().get_nodes_in_group(&"dragon_coin"):
		var _path := i.get_path()
		if !_path: return
		Data.values.dragon_coins_array.append(_path)

func _on_collected() -> void:
	star_coin_filled.visible = true
	star_coin_filled.size.x = STAR_COIN_WIDTH * Data.values.dragon_coins


func _on_all_collected() -> void:
	if !achievement_name || !achievement_progress_to: return
	if !is_instance_valid(unlocker): return
	unlocker.progress_secret()
