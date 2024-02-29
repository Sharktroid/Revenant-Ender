extends MapMenu


func _init() -> void:
	_to_center = true


func select_item(item: MapMenuItem) -> void:
	match item.name:
		"Debug":
			var menu: MapMenu = \
					preload("res://ui/map_ui/map_menus/debug_menu/debug_menu.tscn").instantiate()
			menu.offset = offset
			menu.parent_menu = self
			MapController.get_ui().add_child(menu)
			visible = false
		"End":
			close()
			MapController.map.end_turn()
		var node_name: push_error("%s is not a valid menu item" % node_name)
	super(item)


func close() -> void:
	super()
	CursorController.enable()
