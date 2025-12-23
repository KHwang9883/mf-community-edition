extends RefCounted
class_name MCItem

var type: int
var texture: Texture2D
var item_tile: ItemTile
var item_body: ItemBody
var object_ref: Node2D

class ItemTile:
	var tile_data: TileData
	var coords: Vector2i
	var atlas_coords: Vector2i
	var source_id: int
	var atlas_source: TileSetAtlasSource
	var scenes_source: TileSetScenesCollectionSource
	var alt_id: int
	var scene: PackedScene

class ItemBody:
	var collision_layer: int
	var process_mode: Node.ProcessMode
	var resource_path: String
	var body_process: Node.ProcessMode
