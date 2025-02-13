extends ByNodeScript

func _ready():
	if Data.values.onetime_blocks == false:
		node.start_from_sec[0] = 6.7
