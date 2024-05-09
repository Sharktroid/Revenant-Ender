extends Control

var observing_unit: Unit


func update() -> void:
	var ranks: Array[Node] = []
	for control: Control in $"WeaponRanks/GridContainer".get_children() as Array[Control]:
		if control.get_index() % 2 == 0:
			ranks.append(control)
	for child: Node in $"ItemPanel/ItemLabelContainer".get_children():
		for grandchild: Node in child.get_children():
			grandchild.queue_free()
	var item_labels: Array[Node] = []
	for item: Item in observing_unit.items:
		const ITEM_LABEL_PATH: String = "res://ui/map_ui/item_label/item_label"
		const ITEM_LABEL_NODE: PackedScene = preload(ITEM_LABEL_PATH + ".tscn")
		var item_label := ITEM_LABEL_NODE.instantiate() as ItemLabel
		item_label.item = item
		item_label.set_equip_status(observing_unit)
		$"ItemPanel/ItemLabelContainer".add_child(item_label)
		item_labels.append(item_label)

	await get_tree().process_frame
	for item_label: ItemLabel in item_labels as Array[ItemLabel]:
		var closest_rank: Control = Utilities.get_control_within_height(item_label, ranks)
		item_label.focus_neighbor_right = item_label.get_path_to(closest_rank)
	for rank: Control in ranks as Array[Control]:
		var closest_item_label: Control = Utilities.get_control_within_height(rank, item_labels)
		rank.focus_neighbor_left = rank.get_path_to(closest_item_label)

	for index in item_labels.size():
		Utilities.set_neighbor_path("top", index, -1, item_labels)
		Utilities.set_neighbor_path("bottom", index, 1, item_labels)
	for type: String in Weapon.Types.keys() as Array[String]:
		var rank_node_name: String = "%sRank" % str(type).to_pascal_case()
		const RANK_LABEL = preload(
			"res://ui/map_ui/status_screen/item_screen/weapon_rank_label/weapon_rank_label.gd"
		)
		var rank_label := $"WeaponRanks/GridContainer".get_node(rank_node_name) as RANK_LABEL
		rank_label.weapon_rank = observing_unit.weapon_levels.get(Weapon.Types[type], 0)


func get_item_labels() -> Array[Node]:
	return $"ItemPanel/ItemLabelContainer".get_children()
