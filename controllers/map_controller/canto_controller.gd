class_name CantoController
extends SelectedUnitController

var _movement_tiles: Node2D


func _init(unit: Unit) -> void:
	_movement_tiles = MapController.map.display_tiles(
		unit.get_movement_tiles(), Map.TileTypes.MOVEMENT, 1.0
	)
	unit.selected = true
	super(unit)


func close() -> void:
	remove_tiles()
	_unit.selected = false
	super()


func remove_tiles() -> void:
	if is_instance_valid(_movement_tiles):
		_movement_tiles.queue_free()


func _position_selected() -> void:
	const MenuScript = preload("res://ui/map_ui/map_menus/canto_menu/canto_menu.gd")
	var menu_node := load("res://ui/map_ui/map_menus/canto_menu/canto_menu.tscn") as PackedScene
	var menu := menu_node.instantiate() as MenuScript
	menu.connected_unit = _unit
	menu.offset = (
		CursorController.screen_position
		+ MapController.get_map_camera().get_map_offset()
		+ Vector2i(16, -8)
	)
	menu.caller = self
	CursorController.disable()
	MapController.get_ui().add_child(menu)


func _canceled() -> void:
	pass
