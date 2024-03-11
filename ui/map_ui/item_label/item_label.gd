class_name ItemLabel
extends HelpContainer

var item: Item:
	set(value):
		item = value
		update.call_deferred()


func update() -> void:
	($Icon as TextureRect).texture = item.icon
	($Name as Label).text = item.name
	($"Current Uses" as Label).text = str(item.current_uses)
	($"Max Uses" as Label).text = str(item.max_uses)
	help_description = item.get_description()
	if item is Weapon:
		help_table = (item as Weapon).get_stat_table()
		table_columns = 6
	else:
		help_table = []


func set_equip_status(unit: Unit) -> void:
	var equip_status := $"Equip Status" as Label
	if item == unit.get_current_weapon():
		equip_status.text = "W"
		equip_status.add_theme_color_override("font_color", Color.ROYAL_BLUE)
	else:
		equip_status.text = ""

	var item_name := $Name as Label
	if item is Weapon and unit.can_use_weapon(item as Weapon):
		item_name.theme_type_variation = ""
	else:
		item_name.theme_type_variation = "GreyLabel"
