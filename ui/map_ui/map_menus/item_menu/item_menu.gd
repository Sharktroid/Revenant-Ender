extends MapMenu

var connected_unit: Unit

var _items: Array[Item] = []
const _MENU_ITEM_NODE: GDScript = preload("res://ui/map_ui/map_menus/item_menu" +
		"/item_menu_item/item_menu_item.gd")


func _enter_tree() -> void:
	_update()
	reset_size()
	super()


func _process(_delta: float) -> void:
	_update()


func select_item(item: MapMenuItem) -> void:
	var menu: MapMenu = preload("res://ui/map_ui/map_menus/item_menu/item_options_menu/\
item_options_menu.tscn").instantiate()
	menu.offset = offset + Vector2(16, 20)
	menu.parent_menu = self
	menu.unit = connected_unit
	menu.item = item.item
	MapController.get_ui().add_child(menu)
	super(item)


func close() -> void:
	parent_menu.update()
	super()


func _update() -> void:
	if _items != connected_unit.items:
		_items = connected_unit.items.duplicate()
		if len(_items) <= 0:
			close()
		for child: Node in $Items.get_children():
			child.queue_free()
			await child.tree_exited
		for item: Item in connected_unit.items:
			var item_node: HelpContainer = _MENU_ITEM_NODE.new(item)
			item_node.help_description = item.get_description()
			$Items.add_child(item_node)
