extends MapMenu

signal selection_made(confirmed: bool)

const _CONFIRMATION_MAP_MENU := preload(
	"res://ui/map_ui/map_menus/confirmation_map_menu/confirmation_map_menu.gd"
)

var default_yes: bool = false


func _enter_tree() -> void:
	if not default_yes:
		set_current_item_node($Items/No as HelpContainer)
	super()


static func instantiate(new_offset: Vector2, parent: MapMenu) -> _CONFIRMATION_MAP_MENU:
	const ConfirmationMapMenu = preload(
		"res://ui/map_ui/map_menus/confirmation_map_menu/confirmation_map_menu.tscn"
	)
	return _base_instantiate(ConfirmationMapMenu, new_offset, parent) as _CONFIRMATION_MAP_MENU


func select_item(menu_item: MapMenuItem) -> void:
	selection_made.emit(menu_item.name == "Yes")
	queue_free()
	super(menu_item)
