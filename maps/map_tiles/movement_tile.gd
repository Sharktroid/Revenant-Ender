class_name MovementTile
extends Sprite2D


func _init() -> void:
	_update_frame()


func _process(_delta: float) -> void:
	_update_frame()


static func instantiate(new_position: Vector2i, alpha: float) -> MovementTile:
	return _base_instantiate(
		preload("res://maps/map_tiles/movement_tile.tscn"), new_position, alpha
	)


static func _base_instantiate(
	packed_scene: PackedScene, new_position: Vector2i, alpha: float
) -> MovementTile:
	var scene := packed_scene.instantiate() as MovementTile
	scene.position = new_position
	scene.modulate.a = alpha
	return scene


func _update_frame() -> void:
	frame = floori(float(Engine.get_physics_frames()) / 3) % 16
