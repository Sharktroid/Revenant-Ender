extends Control

var observing_unit: Unit
const _ITEM_LABEL_NODE: PackedScene = \
		preload("res://ui/map_ui/item_label/item_label.tscn")


func _enter_tree() -> void:
	var grid: GridContainer = $"Weapon Ranks/GridContainer"
	var count: int = grid.get_child_count()
	var subfunc: Callable = func(neighbor_name: String, index: int, modifier: int) -> void:
		var new_index: int = index + modifier
		if new_index >= 0 and new_index < count:
			grid.get_child(index).set("focus_neighbor_%s" % neighbor_name,
					grid.get_child(index).get_path_to(grid.get_child(new_index)))
			if neighbor_name == "left":
				print_debug(grid.get_child(index))
				print_debug(grid.get_child(index).get("focus_neighbor_%s" % neighbor_name))
	for index in count:
		subfunc.call("top", index, -2)
		subfunc.call("bottom", index, 2)
		if (index % 2 == 0):
			subfunc.call("right", index, 1)
		else:
			subfunc.call("left", index, -1)


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
