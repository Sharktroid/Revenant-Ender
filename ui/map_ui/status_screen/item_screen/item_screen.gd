extends Control

var observing_unit: Unit
const _ITEM_LABEL_NODE: PackedScene = \
		preload("res://ui/map_ui/item_label/item_label.tscn")


func _enter_tree() -> void:
	var grid: GridContainer = $"Weapon Ranks/GridContainer"
	var count: int = grid.get_child_count()
	for index in count:
		Utilities.set_neighbor_path("top", index, -2, grid)
		Utilities.set_neighbor_path("bottom", index, 2, grid)
		if (index % 2 == 0):
			Utilities.set_neighbor_path("right", index, 1, grid)
		else:
			Utilities.set_neighbor_path("left", index, -1, grid)


func update() -> void:
	for child: Node in $"Item Panel/Item Label Container".get_children():
		for grandchild: Node in child.get_children():
			grandchild.queue_free()
	for item: Item in observing_unit.items:
		var item_label: HelpContainer = _ITEM_LABEL_NODE.instantiate()
		item_label.item = item
		item_label.set_equip_status(observing_unit)
		$"Item Panel/Item Label Container".add_child(item_label)

	for type: String in Weapon.types:
		var rank_node_name: String = "%s Rank" % str(type).capitalize()
		var rank_label: HelpContainer = $"Weapon Ranks/GridContainer".get_node(rank_node_name)
		rank_label.weapon_rank = observing_unit.weapon_levels.get(Weapon.types[type], 0)
