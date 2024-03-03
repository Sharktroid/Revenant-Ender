extends Control

var observing_unit: Unit
const _ITEM_LABEL_NODE: PackedScene = \
		preload("res://ui/map_ui/item_label/item_label.tscn")


func update() -> void:
	var label_container: VBoxContainer = $"Item Panel/Item Label Container"
	var ranks: Array[Node] = []
	for control: Control in $"Weapon Ranks/GridContainer".get_children():
		if control.get_index() % 2 == 0:
			ranks.append(control)
	for child: Node in label_container.get_children():
		for grandchild: Node in child.get_children():
			grandchild.queue_free()
	var item_labels: Array[Node] = []
	for item: Item in observing_unit.items:
		var item_label: HelpContainer = _ITEM_LABEL_NODE.instantiate()
		item_label.item = item
		item_label.set_equip_status(observing_unit)
		$"Item Panel/Item Label Container".add_child(item_label)
		item_labels.append(item_label)
	await get_tree().process_frame
	for item_label: ItemLabel in item_labels:
		var closest_rank: Control = (Utilities.get_control_within_height(item_label, ranks))
		item_label.focus_neighbor_right = item_label.get_path_to(closest_rank)
	for rank: Control in ranks:
		var closest_item_label: Control = Utilities.get_control_within_height(rank, item_labels)
		rank.focus_neighbor_left = rank.get_path_to(closest_item_label)


	for index in label_container.get_child_count():
		Utilities.set_neighbor_path("top", index, -1, label_container)
		Utilities.set_neighbor_path("bottom", index, 1, label_container)
	for type: String in Weapon.types:
		var rank_node_name: String = "%s Rank" % str(type).capitalize()
		var rank_label: HelpContainer = $"Weapon Ranks/GridContainer".get_node(rank_node_name)
		rank_label.weapon_rank = observing_unit.weapon_levels.get(Weapon.types[type], 0)


func get_item_labels() -> Array[Node]:
	return $"Item Panel/Item Label Container".get_children()
