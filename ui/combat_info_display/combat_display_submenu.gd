## A menu that displays possible weapons for the combat panel
extends MapMenu

## Emits the selected weapon when the selected weapon is changed.
signal weapon_selected(weapon: Weapon)

const _ITEM_MENU_ITEM = preload("res://ui/combat_info_display/combat_display_menu_item.gd")

## The weapons that are being displayed.
var weapons: Array[Weapon]:
	set(value):
		if weapons != value:
			weapons = value
			_update()
## The index of the currently selected item
var current_item_index: int:
	set(value):
		_current_item_index = value
	get:
		return _current_item_index


func _enter_tree() -> void:
	super()


func set_current_item_node(item: HelpContainer) -> void:
	super(item)
	weapon_selected.emit((item as _ITEM_MENU_ITEM).item)


func _update() -> void:
	var items := %Items as VBoxContainer
	for child: Node in items.get_children():
		child.queue_free()
		await child.tree_exited
	for weapon: Weapon in weapons:
		items.add_child(_ITEM_MENU_ITEM.new(weapon))
