class_name ItemMenu
extends MapMenu

const _ITEM_MENU_ITEM = preload(
	"res://ui/map_ui/map_menus/item_menu/item_menu_item/item_menu_item.gd"
)

var connected_unit: Unit

var _items: Array[Item] = []


func _init() -> void:
	_to_center = true


func _enter_tree() -> void:
	_update()
	reset_size()
	super()


func _process(_delta: float) -> void:
	_update()


static func instantiate(new_offset: Vector2, parent: MapMenu, unit: Unit = null) -> ItemMenu:
	var packed_scene := load("res://ui/map_ui/map_menus/item_menu/item_menu.tscn") as PackedScene
	var scene := _base_instantiate(packed_scene, new_offset, parent) as ItemMenu
	scene.connected_unit = unit
	return scene


func _select_item(item: MapMenuItem) -> void:
	var menu := ItemOptionsMenu.instantiate(
		_offset + Vector2(16, 20), self, connected_unit, (item as _ITEM_MENU_ITEM).item
	)
	MapController.get_ui().add_child(menu)
	super(item)


func _update() -> void:
	if _items != connected_unit.items:
		_items = connected_unit.items.duplicate()
		if _items.is_empty():
			queue_free()
		for child: Node in $Items.get_children():
			child.queue_free()
			await child.tree_exited
		for item: Item in connected_unit.items:
			$Items.add_child(_ITEM_MENU_ITEM.new(item))
		reset_size()
