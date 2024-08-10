extends MapMenu


func _init() -> void:
	_to_center = true


static func instantiate(new_offset: Vector2, parent: MapMenu = null) -> MapMenu:
	return _base_instantiate(
		preload("res://ui/map_ui/map_menus/main_map_menu/main_map_menu.tscn"), new_offset, parent
	)


func _select_item(item: MapMenuItem) -> void:
	match item.name:
		"Debug":
			const DebugMenu = preload("res://ui/map_ui/map_menus/debug_menu/debug_menu.gd")
			var menu := DebugMenu.instantiate(_offset, self)
			MapController.get_ui().add_child(menu)
			visible = false
		"End":
			_close()
			MapController.map.end_turn()
		var node_name:
			push_error("%s is not a valid menu item" % node_name)
	super(item)


func _close() -> void:
	super()
	CursorController.enable()
