extends MapMenu
var item: Item
var unit: Unit


func _ready() -> void:
	if not item is Weapon:
		$Items/Equip.visible = false
	if not item.can_use():
		$Items/Use.visible = false
	if not item.can_drop():
		$Items/Drop.visible = false
	reset_size()
	super()


func select_item(menu_item: MapMenuItem) -> void:
	match menu_item.name:
		"Equip":
			unit.equip_weapon(item as Weapon)
			close()
		"Use":
			item.use()
			close()
		"Drop":
			var menu: MapMenu = load("uid://c8ty86xbmwj3x").instantiate()
			menu.offset = offset + Vector2(16, 16)
			menu.parent_menu = self
			MapController.get_ui().add_child(menu)
			var drop: bool = await menu.selection_made
			if drop:
				unit.drop(item)
				close()
			menu.queue_free()
	super(menu_item)
