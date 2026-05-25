extends Node2D

@onready var label_page_number: Label = $"../Label3"
@onready var left_pager: StaticBumpingBlock = $LeftPager
@onready var right_pager: StaticBumpingBlock = $RightPager
@onready var pipes: Array[VBoxContainer] = [
	$"../text blah blah2", $"../text blah blah3", $"../text blah blah4"
]
@onready var classic_page: VBoxContainer = $"../text blah blah"

@onready var init_pos: Vector2 = pipes[0].position
@onready var label_percent: Label = $"../LabelPercent"

var page: int = 0
var total_pages: int = 3
var tw: Tween
var completion: float

func _ready() -> void:
	process_mode = PROCESS_MODE_INHERIT
	show()
	for i in pipes:
		i.visible = false
		i.position = init_pos
	
	_update_label_5()
	pipes[page].visible = true
	left_pager.bumped.connect(left_bumped)
	right_pager.bumped.connect(right_bumped)
	await get_tree().physics_frame
	if !is_inside_tree(): return
	for i in pipes:
		completion += i.get_percentage()
	completion += classic_page.get_percentage()
	completion *= 25
	label_percent.text %= completion


func left_bumped() -> void:
	page = clampi(page - 1, 0, total_pages - 1)
	if page == 0:
		left_pager.active = false
	right_pager.active = true
	switch_page()


func right_bumped() -> void:
	page = clampi(page + 1, 0, total_pages - 1)
	if page == total_pages - 1:
		right_pager.active = false
	left_pager.active = true
	switch_page()


func switch_page() -> void:
	for i in len(pipes):
		pipes[i].visible = false
	pipes[page].paginator_play_animation()
	
	_update_label_5()


func _update_label_5() -> void:
	label_page_number.text = "page %d / %d" % [page + 1, total_pages]
