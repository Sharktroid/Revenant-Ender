extends Control

const _RANK_LABEL = preload(
	"res://ui/map_ui/status_screen/item_screen/weapon_rank_label/weapon_rank_label.gd"
)

var observing_unit: Unit:
	set(value):
		observing_unit = value
		_update()


func _update() -> void:
	var get_left_control: Callable = func(control: Control) -> bool:
		return control.get_index() % 2 == 0
	var ranks: Array[Control] = []
	ranks.assign($WeaponRanks/GridContainer.get_children().filter(get_left_control))
	for child: Node in $ItemPanel/ItemLabelContainer.get_children():
		for grandchild: Node in child.get_children():
			grandchild.queue_free()
	var item_labels: Array[Control] = []
	for item: Item in observing_unit.items:
		var item_label := ItemLabel.instantiate(item, observing_unit)
		$ItemPanel/ItemLabelContainer.add_child(item_label)
		item_labels.append(item_label)

	await get_tree().process_frame
	if not item_labels.is_empty():
		for item_label: ItemLabel in item_labels as Array[ItemLabel]:
			item_label.focus_neighbor_right = item_label.get_path_to(
				Utilities.get_control_within_height(item_label, ranks)
			)
		for rank: Control in ranks as Array[Control]:
			rank.focus_neighbor_left = rank.get_path_to(
				Utilities.get_control_within_height(rank, item_labels)
			)

	var item_label_nodes: Array[Node] = []
	item_label_nodes.assign(item_labels)
	for index: int in item_labels.size():
		Utilities.set_neighbor_path("top", index, -1, item_label_nodes)
		Utilities.set_neighbor_path("bottom", index, 1, item_label_nodes)
	for type: String in Weapon.Types.keys() as Array[String]:
		_get_rank_label(type).weapon_rank = observing_unit.weapon_levels.get(Weapon.Types[type], 0)


func get_item_labels() -> Array[Node]:
	return $ItemPanel/ItemLabelContainer.get_children()


func get_rank_labels() -> Array[Node]:
	return $WeaponRanks/GridContainer.get_children()


func _get_rank_label(type: String) -> _RANK_LABEL:
	return $WeaponRanks/GridContainer.get_node("%sRank" % str(type).to_pascal_case())
