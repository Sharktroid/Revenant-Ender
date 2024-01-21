class_name ItemLabel
extends HelpContainer

var item: Item:
	set(value):
		item = value
		update.call_deferred()


func update() -> void:
	$Icon.texture = item.icon
	$Name.text = item.name
	$"Current Uses".text = str(item.current_uses)
	$"Max Uses".text = str(item.max_uses)
	help_description = item.get_description()


func set_equip_status(unit: Unit) -> void:
	var equip_status: Label = $"Equip Status"
	if item == unit.get_current_weapon():
		equip_status.text = "W"
		equip_status.add_theme_color_override("font_color", Color.ROYAL_BLUE)
	else:
		equip_status.text = ""

	var item_name: Label = $Name
	if item is Weapon and unit.can_use_weapon(item as Weapon):
		item_name.theme_type_variation = ""
	else:
		item_name.theme_type_variation = "GreyLabel"
