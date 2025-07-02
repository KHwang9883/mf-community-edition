extends Control

func _init() -> void:
	if Data.values.checkpoint == -1 && !Data.values.get("dragon_coin_life", false):
		Data.values.dragon_coins = 0
		Data.values.dragon_coins_max = 3

func _ready() -> void:
	if !Data.has_user_signal(&"dragon_coin_collected"):
		Data.add_user_signal(&"dragon_coin_collected")
	
	if Data.values.onetime_blocks:
		Data.values.dragon_coin_life = false
	
	if Data.values.checkpoint == -1 && !Data.values.dragon_coin_life:
		print(Data.values.dragon_coin_life)
		Data.values.dragon_coins = 0
		Data.values.dragon_coins_max = get_tree().get_node_count_in_group(&"dragon_coin")
		Data.values.dragon_coins_array = []
	
	if Data.values.checkpoint != -1 && !Data.values.dragon_coin_life:
		Data.values.dragon_coins = Data.values.dragon_coins_max - len(Data.values.dragon_coins_array)
	
	Thunder._connect(Data.checkpoint_set, _on_checkpoint_set)

func _on_checkpoint_set() -> void:
	Data.values.dragon_coins_array = []
	for i in get_tree().get_nodes_in_group(&"dragon_coin"):
		var _path := i.get_path()
		if !_path: return
		Data.values.dragon_coins_array.append(_path)
