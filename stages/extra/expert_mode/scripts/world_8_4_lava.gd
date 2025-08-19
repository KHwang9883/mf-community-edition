extends Node2D

@onready var sound: AudioStreamPlayer2D = $SoundRising
@onready var lava_bowser: Node2D = $LavaBowser
@onready var light_effect_lava: Node2D = $LightEffectLava
#@onready var podoboos: Node2D = $"../../Podoboos"
#@onready var podoboos_arr: Array
@onready var path_follow_2d: PathFollow2D = $".."

var lava_arr_bottom: Array[Node2D]

var s_timer: float
var s_freq: float = 0
var lava_offset: float
var lava_step: int
var tw: Tween

func _ready() -> void:
	#podoboos_arr = podoboos.get_children()
	
	var lava_base = lava_bowser.get_child(0)
	lava_arr_bottom.resize(20)
	lava_arr_bottom[0] = lava_base
	for i in 19:
		var more_lava = lava_base.duplicate()
		more_lava.position.x = 32 * (i + 1)
		lava_bowser.add_child(more_lava)
		lava_arr_bottom[i + 1] = more_lava
		
		if i % 3 == 0:
			var more_light = light_effect_lava.duplicate()
			more_lava.add_child(more_light)

	light_effect_lava.queue_free()

func _physics_process(delta: float) -> void:
	s_timer += delta
	match lava_step:
		0 when path_follow_2d.progress > 80:
			lava_step += 1
			sound.play()
			s_freq = 4
			if tw && tw.is_valid(): tw.kill()
			tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			tw.tween_property(self, "position:y", -256, 2.0)
		1 when path_follow_2d.progress > 640:
			lava_step += 1
			sound.play()
			if tw && tw.is_valid(): tw.kill()
			tw = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
			tw.tween_property(self, "s_freq", 96, 2.0)
	lava_loop()

func lava_loop() -> void:
	#lava_offset = -128
	for i in len(lava_arr_bottom):
		lava_arr_bottom[i].position.y = lava_offset + sin(s_timer + (i * 0.31) + PI) * s_freq
