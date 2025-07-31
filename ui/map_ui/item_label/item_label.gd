class_name ItemLabel
extends HelpContainer

var _item: Item:
	set(value):
		_item = value
		_update.call_deferred()
var _unit: Unit


static func instantiate(connected_item: Item, unit: Unit) -> ItemLabel:
	var scene := preload("res://ui/map_ui/item_label/item_label.tscn").instantiate() as ItemLabel
	scene._item = connected_item
	scene._unit = unit
	return scene


func set_as_current_help_container() -> void:
	var pages: Array[Array] = []
	if _item is Weapon:
		var weapon := (_item as Weapon)
		for mode: Weapon in weapon.get_weapon_modes():
			var page: Array[Control]
			page.append(mode.get_stat_table().to_grid_container())
			page.append(HelpPopupController.create_text_node(mode.get_flavor_text()))
			var description: String = mode.get_description()
			if description.length() > 0:
				page.append(HelpPopupController.create_text_node(description))
			pages.append(page)
	else:
		pass
	HelpPopupController.set_help_nodes(
		pages,
		global_position + Vector2(size.x / 2, 0).round(),
		self
	)


func _update() -> void:
	($Icon as TextureRect).texture = _item.get_icon()
	($Name as Label).text = _item.resource_name
	($CurrentUses as Label).text = Utilities.float_to_string(_item.current_uses, true)
	($MaxUses as Label).text = Utilities.float_to_string(_item.get_max_uses(), true)
	_set_equip_status()


func _set_equip_status() -> void:
	var equip_status := $EquipStatus as Label
	if _item == _unit.get_weapon():
		equip_status.text = "W"
		equip_status.add_theme_color_override("font_color", Color.ROYAL_BLUE)
	else:
		equip_status.text = ""
	($Name as Label).theme_type_variation = _get_type_variation()


func _get_type_variation() -> StringName:
	if _item is Weapon:
		if _unit.can_use_weapon(_item as Weapon):
			return &""
		else:
			return &"GrayLabel"
	else:
		return &""
