class_name ItemOptionsMenu
extends MapMenu
var item: Item
var unit: Unit


func _enter_tree() -> void:
	if not item is Weapon:
		($Items/Equip as MapMenuItem).visible = false
	if not item.is_usable():
		($Items/Use as MapMenuItem).visible = false
	if not item.is_droppable():
		($Items/Drop as MapMenuItem).visible = false
	reset_size.call_deferred()
	super()


static func instantiate(
	new_offset: Vector2, parent: MapMenu, connected_unit: Unit = null, displayed_item: Item = null
) -> ItemOptionsMenu:
	const PACKED_SCENE = preload(
		"res://ui/map_ui/map_menus/item_menu/item_options_menu/item_options_menu.tscn"
	)
	var scene := _base_instantiate(PACKED_SCENE, new_offset, parent) as ItemOptionsMenu
	scene.unit = connected_unit
	scene.item = displayed_item
	return scene


func select_item(menu_item: MapMenuItem) -> void:
	match menu_item.name:
		"Equip":
			unit.equip_weapon(item as Weapon)
			close()
		"Use":
			item.use()
			close()
		"Drop":
			var menu := ConfirmationMapMenu.instantiate(offset + Vector2(16, 16), self)
			MapController.get_ui().add_child(menu)
			if await menu.selection_made:
				unit.drop(item)
				close()
	super(menu_item)
