class_name ConfirmationMapMenu
extends MapMenu

signal selection_made(confirmed: bool)

var default_yes: bool = false


func _enter_tree() -> void:
	if not default_yes:
		set_current_item_node($Items/No as HelpContainer)
	super()


static func instantiate(new_offset: Vector2, parent: MapMenu) -> ConfirmationMapMenu:
	const PACKED_SCENE = preload(
		"res://ui/map_ui/map_menus/confirmation_map_menu/confirmation_map_menu.tscn"
	)
	return _base_instantiate(PACKED_SCENE, new_offset, parent) as ConfirmationMapMenu


func _select_item(menu_item: MapMenuItem) -> void:
	selection_made.emit(menu_item.name == "Yes")
	queue_free()
	super(menu_item)
