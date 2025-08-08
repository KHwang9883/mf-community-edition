extends Node2D

const DROPPED_ITEM = preload("res://commands/minec/dropped_item.tscn")

enum OutlineType {
	PLACEABLE = -1,
	NONE = 0,
	BODY = 1,
	TILE_MAP_LAYER = 2,
	TILE_MAP = 3,
}

var outlined: CollisionObject2D
var outlined_tilemap: TileMapLayer
var outlined_tilemap_item: MCItem.ItemTile
var outlined_center_pos: Vector2
var outline_type: OutlineType
#var outlined_id: int
var breaking: float
var _saved_mouse_pos: Vector2
#var _last_outlined: Variant
var collision_mask: int = 16 + 64
var can_place: bool

@onready var gui = Scenes.custom_scenes.get("MinecraftGUI")
@onready var breaking_sprite: Sprite2D = $Breaking

func _ready() -> void:
	Scenes.custom_scenes.MinecraftOutline = self
	if !is_instance_valid(gui):
		await get_tree().physics_frame
		gui = Scenes.custom_scenes.get("MinecraftGUI")
		gui.evil_mode_activated.connect(func():
			collision_mask = 2 + 16 + 64
		)
		gui.evil_mode_deactivated.connect(func():
			collision_mask = 16 + 64
		)

func _physics_process(delta: float) -> void:
	if !is_instance_valid(gui):
		return
	
	if !Thunder._current_player.completed:
		check_tile_process()
	
	breaking_process(delta)

## Checking what is under the mouse cursor and setting variables accordingly
func check_tile_process() -> void:
	var query := PhysicsPointQueryParameters2D.new()
	query.collision_mask = collision_mask
	_saved_mouse_pos = get_global_mouse_position()
	query.position = _saved_mouse_pos
	
	var cldata: Array[Dictionary] = get_world_2d().direct_space_state.intersect_point(query, 10)
	var has_something: bool
	
	for k in cldata:
		var l: Object = k.get(&"collider", null)
		if !l: continue
		#print(l)
		if l is CollisionObject2D:
			outlined = l
			outlined_tilemap = null
			outlined_tilemap_item = null
			outlined_center_pos = l.global_position
			outline_type = OutlineType.BODY
			has_something = true
			break
		
		elif l is TileMapLayer:
			outlined = null
			var tile_pos = l.local_to_map(l.to_local(_saved_mouse_pos))
		#print(tile_pos)
			var tile_data: TileData = l.get_cell_tile_data(tile_pos)
			var cell_source: int = l.get_cell_source_id(tile_pos)
			if !tile_data || cell_source == -1:
				continue
			
			outlined_tilemap_item = MCItem.ItemTile.new()
			outlined_tilemap_item.tile_data = tile_data
			outlined_tilemap_item.coords = tile_pos
			var _source = l.tile_set.get_source(cell_source)
			if _source is TileSetAtlasSource:
				outlined_tilemap_item.atlas_source = _source
				outlined_tilemap_item.atlas_coords = l.get_cell_atlas_coords(tile_pos)
			elif _source is TileSetScenesCollectionSource:
				outlined_tilemap_item.scenes_source = _source
				var alt_id = l.get_cell_alternative_tile(tile_pos)
				outlined_tilemap_item.scene = _source.get_scene_tile_scene(alt_id)
			
			outlined_center_pos = l.to_global(l.map_to_local(tile_pos))
			outline_type = OutlineType.TILE_MAP_LAYER
			outlined_tilemap = l
			has_something = true
			break
	
	if !has_something:
		outlined = null
		outlined_tilemap = null
		outlined_tilemap_item = null
		outlined_center_pos = Vector2.ONE * 16 + Vector2(_saved_mouse_pos / 32).floor() * 32
		#print(outlined_center_pos)
		outline_type = OutlineType.NONE
		var item = gui.inventory[gui.selected]
		if item:
			var place_query := PhysicsShapeQueryParameters2D.new()
			place_query.collision_mask = 0b1110111
			place_query.transform = Transform2D(0, outlined_center_pos)
			#print(place_query.transform)
			var shape_rid = PhysicsServer2D.rectangle_shape_create()
			PhysicsServer2D.shape_set_data(shape_rid, Vector2.ONE * 15)
			place_query.shape_rid = shape_rid
			
			
			var cls := get_world_2d().direct_space_state.intersect_shape(place_query, 1)
			PhysicsServer2D.free_rid(shape_rid)
			var detected: bool = false
			if len(cls) > 0:
				#print(cls[0])
				if cls[0].get("collider"):
					detected = true
			
			if !detected:
				outline_type = OutlineType.PLACEABLE
			can_place = !detected
		else:
			can_place = false
	else:
		can_place = false
	#if outlined:
	#	print(outlined)
	queue_redraw()

## Drawing outline of a tile under mouse cursor
func _draw() -> void:
	var _rect: Rect2
	var _polygons: Array[PackedVector2Array]
	var _color := Color(0, 0, 0, 0.5)
	if is_instance_valid(outlined):
		for i in outlined.get_shape_owners():
			draw_set_transform(outlined.shape_owner_get_owner(i).global_position)
			for j in outlined.shape_owner_get_shape_count(i):
				_rect = (outlined.shape_owner_get_shape(i, j).get_rect())
	elif is_instance_valid(outlined_tilemap):
		var tile_pos = outlined_tilemap.local_to_map(outlined_tilemap.to_local(_saved_mouse_pos))
		#print(tile_pos)
		var tile_data: TileData = outlined_tilemap.get_cell_tile_data(tile_pos)
		if !tile_data:
			return
		var gl_pos = outlined_tilemap.to_global(
			outlined_tilemap.map_to_local(tile_pos)
		)
		draw_set_transform(gl_pos)
		for i in tile_data.get_collision_polygons_count(0):
			_polygons.append(tile_data.get_collision_polygon_points(0, i))
	elif can_place:
		draw_set_transform(outlined_center_pos)
		_rect = Rect2i(-16, -16, 32, 32)
		_color = Color(0, 1.0, 0, 0.5)
		
	if _rect:
		#_rect = _rect.grow(1)
		#print(_rect)
		draw_rect(_rect, _color, false, 4.0, false)
	elif _polygons:
		for i in len(_polygons):
			# _polygons[i][len(_polygons[i]) - 1]
			_polygons[i].append(Vector2(_polygons[i][0].x, _polygons[i][0].y))
			#print(_polygons[i])
			draw_polyline(_polygons[i], Color(0, 0, 0, 0.5), 4.0)

## Breaking tiles (holding left mouse button)
func breaking_process(delta: float) -> void:
	var can_break: bool = outline_type > OutlineType.NONE
	if outline_type == OutlineType.BODY && !outlined.scene_file_path:
		can_break = false
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && can_break:
		breaking += delta
	else:
		breaking = 0
	breaking_sprite.visible = breaking > 0.0
	breaking_sprite.frame = clampi(ceili(breaking * 15), 0, 9)
	breaking_sprite.global_position = outlined_center_pos
	#print(breaking_sprite.frame)
	
	if breaking > 0.6:
		breaking = -0.15
		block_break()

func block_break() -> void:
	if outline_type <= OutlineType.NONE: return
	if outline_type == OutlineType.BODY && (!is_instance_valid(outlined) || !outlined.scene_file_path):
		return
	var drop = DROPPED_ITEM.instantiate()
	var texture: Texture2D
	drop.item.type = outline_type
	drop.position = outlined_center_pos
	match outline_type:
		OutlineType.BODY:
			drop.item.object_ref = outlined
			drop.item.item_body = MCItem.ItemBody.new()
			drop.item.item_body.collision_layer = outlined.collision_layer
			drop.item.item_body.process_mode = outlined.process_mode
			drop.item.item_body.resource_path = outlined.scene_file_path
			var packed = PackedScene.new()
			packed.pack(outlined)
			texture = _get_packed_scene_texture(packed)
			packed = null
			outlined.hide()
			outlined.process_mode = Node.PROCESS_MODE_DISABLED
			outlined.set_deferred("collision_layer", 0)
			var body = outlined.get_node_or_null("Body")
			if body:
				drop.item.item_body.body_process = body.process_mode
				body.process_mode = Node.PROCESS_MODE_DISABLED
		OutlineType.TILE_MAP_LAYER:
			drop.item.object_ref = outlined_tilemap
			drop.item.item_tile = outlined_tilemap_item
			drop.item.item_tile.source_id = outlined_tilemap.get_cell_source_id(outlined_tilemap_item.coords)
			if outlined_tilemap_item.atlas_source:
				var region = outlined_tilemap_item.atlas_source.get_tile_texture_region(
					outlined_tilemap_item.atlas_coords
				)
				var atlas_texture = AtlasTexture.new()
				atlas_texture.atlas = outlined_tilemap_item.atlas_source.texture
				atlas_texture.region = region
				texture = atlas_texture
			elif outlined_tilemap_item.scenes_source:
				texture = _get_packed_scene_texture(outlined_tilemap_item.scene)
			
			if outlined_tilemap_item.tile_data.terrain > -1:
				outlined_tilemap.set_cells_terrain_connect([outlined_tilemap_item.coords], outlined_tilemap_item.tile_data.terrain_set, -1)
			else:
				outlined_tilemap.set_cell(outlined_tilemap_item.coords, -1)
			
	drop.item.texture = texture
	drop.texture = texture
	Scenes.current_scene.add_child(drop)

#func can_place() -> bool:
	

func _get_packed_scene_texture(scene: PackedScene) -> Texture2D:
	var state = scene.get_state()
	var specific_node = null
	var specific_index: int = -1
	var specific_anim: String
	for i in state.get_node_count():
		if specific_node != null && specific_index == -1:
			#prints(specific_node, str(state.get_node_path(i, false)).right(-2))
			if specific_node == str(state.get_node_path(i, false)).right(-2):
				specific_index = i
		if specific_index != -1 && i != specific_index:
			continue
		for j in state.get_node_property_count(i):
			var propname = state.get_node_property_name(i, j)
			#if state.get_node_type(i) == &"AnimatedSprite2D":
			#	print(propname)
			if specific_node == null && propname == "sprite":
				specific_node = str(state.get_node_property_value(i, j))
			if propname == "animation":
				specific_anim = state.get_node_property_value(i, j)
				#print(specific_anim)
				continue
			if propname in ["sprite_frames", "texture"]:
				var prop = state.get_node_property_value(i, j)
				if is_instance_of(prop, Texture2D):
					return prop
				elif is_instance_of(prop, SpriteFrames):
					var anim = prop.get_animation_names()[0] if !specific_anim else specific_anim
					return prop.get_frame_texture(anim, 0)
	
	return null

func _input(event) -> void:
	gui = Scenes.custom_scenes.get("MinecraftGUI")
	if !is_instance_valid(gui):
		return
	
	if event is InputEventMouseButton && event.is_pressed():
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			gui.pick_block()
