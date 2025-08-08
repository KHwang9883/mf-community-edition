extends CanvasLayer

signal evil_mode_activated
signal evil_mode_deactivated

const DROPPED_ITEM = preload("res://commands/minec/dropped_item.tscn")

@onready var hotbar: HBoxContainer = $Control/TextureRect/Hotbar
@onready var selector: TextureRect = $Control/TextureRect/Selector

var selected: int
var inventory: Array[ItemSlot]
var reserved_inventory: Array[ItemSlot]

func _ready() -> void:
	inventory.resize(9)
	reserved_inventory.resize(9)
	Scenes.custom_scenes.MinecraftGUI = self
	await get_tree().physics_frame
	if Console.cv.get("mc_enemy_mode"):
		evil_mode_activated.emit()

func push_item(item: MCItem) -> bool:
	var is_full: bool = true
	for i in len(inventory):
		if !inventory[i]:
			inventory[i] = ItemSlot.new()
			inventory[i].type = item.type as ItemSlot.OutlineType
			inventory[i].items = [item]
			if item.type == ItemSlot.OutlineType.BODY && !item.item_body.resource_path:
				inventory[i].exclusive = true
			update_hotbar()
			return false
		elif inventory[i].exclusive:
			continue
		elif inventory[i].type == item.type && _is_same_item(inventory[i].items[0], item):
			inventory[i].items.append(item)
			update_hotbar()
			return false
	return is_full

func try_placing_block() -> void:
	if !inventory[selected]: return
	var outline = Scenes.custom_scenes.get("MinecraftOutline")
	if !outline:
		return
	var item: MCItem = inventory[selected].items.back()
	if !outline.can_place: return
	if !is_instance_valid(item.object_ref):
		return
	if item.type == ItemSlot.OutlineType.BODY:
		item.object_ref.show()
		item.object_ref.process_mode = item.item_body.process_mode
		item.object_ref.set_deferred("collision_layer", item.item_body.collision_layer)
		item.object_ref.global_position = outline.outlined_center_pos
		item.object_ref.reset_physics_interpolation()
		var body = item.object_ref.get_node_or_null("Body")
		if body:
			body.process_mode = item.item_body.body_process
	elif item.type == ItemSlot.OutlineType.TILE_MAP_LAYER:
		var itemtile: MCItem.ItemTile = item.item_tile
		var object: TileMapLayer = item.object_ref
		var tile_pos = object.local_to_map(object.to_local(outline.outlined_center_pos))
		if itemtile.atlas_source:
			if itemtile.tile_data.terrain == -1:
				object.set_cell(tile_pos, itemtile.source_id, itemtile.atlas_coords)
			else:
				object.set_cells_terrain_connect(
					[tile_pos], itemtile.tile_data.terrain_set, itemtile.tile_data.terrain
				)
	
	inventory[selected].items.pop_back()
	update_hotbar()

func pick_block() -> void:
	if !inventory[selected]: return
	var pl := Thunder._current_player
	if !pl: return
	var _item: MCItem = inventory[selected].items.pop_back()
	if !_item:
		update_hotbar()
		return
	var drop = DROPPED_ITEM.instantiate()
	drop.item = _item
	drop.texture = _item.texture
	drop.wait_time = 2.0
	drop.position = pl.global_position
	drop.speed.x = 125 * pl.direction
	Scenes.current_scene.add_child(drop)
	update_hotbar()


func _is_same_item(inv: MCItem, new: MCItem) -> bool:
	if !inv || !inv.object_ref || !new || !new.object_ref:
		return false
	if !inv.item_tile:
		if inv.item_body && inv.item_body.resource_path && new.item_body:
			return inv.item_body.resource_path == new.item_body.resource_path
		return inv.object_ref == new.object_ref
	if !new.item_tile:
		return false
	if inv.item_tile.atlas_source:
		return (
			inv.object_ref == new.object_ref &&
			inv.item_tile.atlas_source == new.item_tile.atlas_source &&
			inv.item_tile.tile_data.terrain == new.item_tile.tile_data.terrain &&
			inv.item_tile.tile_data.terrain_set == new.item_tile.tile_data.terrain_set
		)
	if inv.item_tile.scenes_source:
		return (
			inv.object_ref == new.object_ref &&
			inv.item_tile.scene.get_state().get_node_count() == new.item_tile.scene.get_state().get_node_count()
		)
	return false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed():
		if event.button_index == MOUSE_BUTTON_RIGHT:
			try_placing_block()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			switch_selected(wrapi(selected + 1, 0, 9))
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			switch_selected(wrapi(selected - 1, 0, 9))
	if event.is_action_pressed(&"a_tab"):
		var _prev_inv = inventory
		inventory = reserved_inventory
		reserved_inventory = _prev_inv
		#print(_prev_inv)
		update_hotbar()
		
func switch_selected(to: int) -> void:
	selected = clampi(to, 0, 8)
	selector.position.x = -2 + (selected * 40)

func update_hotbar() -> void:
	for i in len(inventory):
		var slot = hotbar.get_child(i)
		if inventory[i] && len(inventory[i].items) == 0:
			inventory[i] = null
		if !inventory[i]:
			slot.get_node("Texture").texture = null
			slot.get_node("Count").text = ""
			continue
		slot.get_node("Texture").texture = inventory[i].items.back().texture
		if slot.get_node("Texture").texture == null:
			slot.get_node("Texture").texture = preload("res://commands/minec/gfx/unknown.png")
		if inventory[i].exclusive:
			slot.get_node("Count").text = ""
		else:
			slot.get_node("Count").text = str(len(inventory[i].items))


func activate_enemy_mode() -> void:
	evil_mode_activated.emit()

func deactivate_enemy_mode() -> void:
	evil_mode_deactivated.emit()


class ItemSlot:
	enum OutlineType {
		NONE,
		BODY,
		TILE_MAP_LAYER,
		TILE_MAP
	}
	var type: OutlineType
	var items: Array[MCItem]
	var exclusive: bool = false
