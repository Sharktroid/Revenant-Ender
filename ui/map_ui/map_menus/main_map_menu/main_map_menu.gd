extends MapMenu


func _ready() -> void:
	_to_center = true
	super()


func select_item(item: MapMenuItem) -> void:
	match item.name:
		"Debug":
			var menu: MapMenu = load("uid://c0mmbk17nyqii").instantiate()
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
	MapController.get_cursor().enable()
