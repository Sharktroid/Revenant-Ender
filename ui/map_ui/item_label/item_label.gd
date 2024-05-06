class_name ItemLabel
extends HelpContainer

var item: Item:
	set(value):
		item = value
		update.call_deferred()


func _init() -> void:
	table_columns = 6


func update() -> void:
	($Icon as TextureRect).texture = item.icon
	($Name as Label).text = item.name
	($CurrentUses as Label).text = str(item.current_uses)
	($MaxUses as Label).text = str(item.max_uses)
	help_description = item.description
	help_table = (item as Weapon).get_stat_table() if item is Weapon else []


func set_equip_status(unit: Unit) -> void:
	var equip_status := $EquipStatus as Label
	if item == unit.get_current_weapon():
		equip_status.text = "W"
		equip_status.add_theme_color_override("font_color", Color.ROYAL_BLUE)
	else:
		equip_status.text = ""

	($Name as Label).theme_type_variation = (
			"" if item is Weapon and unit.can_use_weapon(item as Weapon)
			else "GreyLabel"
	)
