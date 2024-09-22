class_name ItemLabel
extends HelpContainer

var _item: Item:
	set(value):
		_item = value
		_update.call_deferred()
var _unit: Unit


func _init() -> void:
	table_columns = 6


static func instantiate(connected_item: Item, unit: Unit) -> ItemLabel:
	var scene := preload("res://ui/map_ui/item_label/item_label.tscn").instantiate() as ItemLabel
	scene._item = connected_item
	scene._unit = unit
	return scene


func _update() -> void:
	($Icon as TextureRect).texture = _item.get_icon()
	($Name as Label).text = _item.resource_name
	($CurrentUses as Label).text = str(_item.current_uses)
	($MaxUses as Label).text = str(_item.get_max_uses())
	help_description = _item.get_description()
	help_table = (_item as Weapon).get_stat_table() if _item is Weapon else []
	_set_equip_status()


func _set_equip_status() -> void:
	var equip_status := $EquipStatus as Label
	if _item == _unit.get_weapon():
		equip_status.text = "W"
		equip_status.add_theme_color_override("font_color", Color.ROYAL_BLUE)
	else:
		equip_status.text = ""

	($Name as Label).theme_type_variation = (
		"" if _item is Weapon and _unit.can_use_weapon(_item as Weapon) else "GrayLabel"
	)
