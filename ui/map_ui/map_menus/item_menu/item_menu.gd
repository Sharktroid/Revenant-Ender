extends MapMenu

const _ITEM_MENU_ITEM = preload(
	"res://ui/map_ui/map_menus/item_menu/item_menu_item/item_menu_item.gd"
)

var connected_unit: Unit

var _items: Array[Item] = []


func _enter_tree() -> void:
	_update()
	reset_size()
	super()


func _process(_delta: float) -> void:
	_update()


func select_item(item: MapMenuItem) -> void:
	const MENU_PATH: String = (
		"res://ui/map_ui/map_menus/item_menu/item_options_menu/item_options_menu."
	)
	const Menu = preload(MENU_PATH + "gd")
	var menu := (load(MENU_PATH + "tscn") as PackedScene).instantiate() as Menu
	menu.offset = offset + Vector2(16, 20)
	menu.parent_menu = self
	menu.unit = connected_unit
	menu.item = (item as _ITEM_MENU_ITEM).item
	MapController.get_ui().add_child(menu)
	super(item)


func close() -> void:
	const UnitMenu = preload("res://ui/map_ui/map_menus/unit_menu/unit_menu.gd")
	(parent_menu as UnitMenu).update()
	super()


func _update() -> void:
	if _items != connected_unit.items:
		_items = connected_unit.items.duplicate()
		if _items.size() <= 0:
			close()
		for child: Node in $Items.get_children():
			child.queue_free()
			await child.tree_exited
		for item: Item in connected_unit.items:
			var item_node := _ITEM_MENU_ITEM.new(item)
			item_node.help_description = item.get_description()
			$Items.add_child(item_node)
	reset_size()
