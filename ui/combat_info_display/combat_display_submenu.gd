extends MapMenu

signal weapon_selected(weapon: Weapon)

const _ITEM_MENU_ITEM = preload("res://ui/combat_info_display/combat_display_menu_item.gd")

var weapons: Array[Weapon]:
	set(value):
		if weapons != value:
			weapons = value
			_update()


func _enter_tree() -> void:
	super()
	GameController.remove_from_input_stack()


func _update() -> void:
	var items := %Items as VBoxContainer
	for child: Node in items.get_children():
		child.queue_free()
		await child.tree_exited
	for weapon: Weapon in weapons:
		items.add_child(_ITEM_MENU_ITEM.new(weapon))


func set_current_item_node(item: HelpContainer) -> void:
	super(item)
	weapon_selected.emit((item as _ITEM_MENU_ITEM).item)
