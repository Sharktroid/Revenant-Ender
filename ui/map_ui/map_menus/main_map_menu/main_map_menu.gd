extends MapMenu


func select_item(item: MapMenuItem) -> void:
	match item.name:
		"Debug":
			var menu: MapMenu = load("uid://c0mmbk17nyqii").instantiate()
			menu.position = position
			menu.parent_menu = self
			MapController.get_ui().add_child(menu)
			visible = false
		"End":
			close()
			MapController.map.end_turn()
		var name: push_error("%s is not a valid menu item" % name)
	super(item)


func close() -> void:
	super()
	MapController.get_cursor().enable()
