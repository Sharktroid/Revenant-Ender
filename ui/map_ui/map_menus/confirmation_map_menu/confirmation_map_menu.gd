extends MapMenu

signal selection_made(confirmed: bool)

var default_yes: bool = false


func _enter_tree() -> void:
	if not default_yes:
		set_current_item_node($Items/No as HelpContainer)
	super()


func select_item(menu_item: MapMenuItem) -> void:
	match menu_item.name:
		"Yes": selection_made.emit(true)
		"No": selection_made.emit(false)
	super(menu_item)
