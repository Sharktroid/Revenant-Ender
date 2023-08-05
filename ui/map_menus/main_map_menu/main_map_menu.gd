extends MapMenu


func _init():
	item_keys = ["Debug", "Unit", "Status","Guide","Options","Suspend", "End"]


func select_item(item: String) -> void:
	match item:
		"Debug":
			var menu: MapMenu = load("uid://c0mmbk17nyqii").instantiate()
			menu.position = position
			menu.parent_menu = self
			GenVars.map_controller.get_node("UI Layer").add_child(menu)
			visible = false
		"End":
			close()
			GenVars.map.end_turn()
		_: push_error("%s is not a valid menu item" % item)


func close() -> void:
	super()
	(GenVars.cursor as Cursor).enable()
