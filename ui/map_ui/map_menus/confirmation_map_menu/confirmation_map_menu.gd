extends MapMenu

signal selection_made(confirmed: bool)

var default_yes: bool = false


func _enter_tree() -> void:
	if not default_yes:
		set_current_item_node($Items/No as HelpContainer)
	super()


func select_item(menu_item: MapMenuItem) -> void:
	selection_made.emit(menu_item.name == "Yes")
	super(menu_item)
