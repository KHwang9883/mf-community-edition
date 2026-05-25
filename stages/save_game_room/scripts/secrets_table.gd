extends VBoxContainer

signal all_achievements_done

@export var is_paginated: bool = false

@onready var children = get_children()
var tween: Tween
var achievements_number: int
var achievements_unlocked: int

func _ready() -> void:
	if SecretsManager.secrets.is_empty():
		return
	
	var not_done: bool = false
	achievements_number = 0
	
	for child in children:
		if !child.visible: continue
		var achievement = child
		if is_paginated:
			achievement = child.get_child(0)
		if !achievement.visible: continue
		
		var toggler: Label
		var labels = achievement.get_children()
		for i in len(labels):
			if !labels[i] is Label:
				#print(labels[i].get_path())
				continue
			if i == 1:
				toggler = labels[i]
				break
		
		achievements_number += max(1, achievement.progress_to)
		var secr = SecretsManager.secrets.get(achievement.secret_id)
		if typeof(secr) == TYPE_BOOL && secr == true:
			toggle_yes(toggler)
			achievements_unlocked += max(1, achievement.progress_to)
		elif typeof(secr) == TYPE_ARRAY && len(secr) >= achievement.progress_to:
			toggle_yes(toggler)
			achievements_unlocked += max(1, achievement.progress_to)
		else:
			not_done = true
			if typeof(secr) == TYPE_ARRAY && len(secr) > 0:
				toggler.text = "no, %d" % len(secr)
				achievements_unlocked += len(secr)
	
	if !not_done:
		all_achievements_done.emit()


func toggle_yes(label: Label) -> void:
	label.text = "yes"
	label.add_theme_color_override("font_color", Color("a8a0f8"))

func show_achievement(achievement_name: String) -> void:
	if !has_node(achievement_name): return
	get_node(achievement_name).get_child(0).show_hidden()


func paginator_play_animation() -> void:
	if tween && tween.is_valid():
		tween.kill()
	
	if !is_paginated: return
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	var counter: int = 0
	for i: MarginContainer in children:
		if !i.visible: continue
		i.modulate.a = 0
		tween.tween_method((func(new: int):
			i.add_theme_constant_override(&"margin_left", new)
		), -440, 0, 0.5).set_delay(0.01 * counter)
		tween.tween_method((func(new: int):
			i.add_theme_constant_override(&"margin_right", new)
		), 440, 0, 0.5).set_delay(0.01 * counter)
		tween.tween_callback(func():
			i.modulate.a = 1
		).set_delay(0.01 * counter)
		counter += 1
	
	visible = true


func get_percentage() -> float:
	prints("%d / %d" % [achievements_unlocked, achievements_number])
	return float(achievements_unlocked) / float(achievements_number)
