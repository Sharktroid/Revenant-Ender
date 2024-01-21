extends Control

var observing_unit: Unit
const _ITEM_LABEL_NODE: PackedScene = \
		preload("res://ui/map_ui/item_label/item_label.tscn")


func update() -> void:
	for child in $"Item Panel/Item Label Container".get_children():
		for grandchild in child.get_children():
			grandchild.queue_free()
	for item in observing_unit.items:
		var item_label: HelpContainer = _ITEM_LABEL_NODE.instantiate()
		item_label.item = item
		item_label.set_equip_status(observing_unit)
		$"Item Panel/Item Label Container".add_child(item_label)

	for type in Weapon.types:
		var rank_node_name: String = "%s Rank" % str(type).capitalize()
		var rank_label: HelpContainer = $"Weapon Ranks/GridContainer".get_node(rank_node_name)
		rank_label.weapon_rank = observing_unit.weapon_levels.get(Weapon.types[type], 0)
