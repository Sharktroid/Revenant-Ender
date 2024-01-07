class_name MapMenu
extends PanelContainer

enum types {SACRED_STONES, BINDING_BLADE}

var offset: Vector2:
	set(value):
		offset = value
		update_position()
var parent_menu: MapMenu
## If true, the menu will move to the left if on the right side of the screen
var _to_center: bool = false

var _current_item_index: int = 0


func _ready() -> void:
	grab_focus()
	while (get_current_item_node().visible == false):
		_current_item_index += 1
	update_position()


func _has_point(_point: Vector2) -> bool:
	return true


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		_current_item_index -= 1

	elif event.is_action_pressed("down"):
		_current_item_index += 1

	if event.is_action_pressed("ui_accept"):
		select_item(get_current_item_node())
		accept_event()

	elif event.is_action_pressed("ui_cancel"):
		close()


func close() -> void:
	# Closes the menu
	queue_free()
	if parent_menu:
		parent_menu.grab_focus()
		parent_menu.visible = true
	else:
		MapController.map.grab_focus()


func update_position() -> void:
	position = offset.clamp(Vector2i(), Utilities.get_screen_size() - Vector2i(size))
	if (offset.x >= float(Utilities.get_screen_size().x)/2 and _to_center):
		var cursor_pos: int = MapController.get_cursor().get_true_pos().x \
				+ MapController.get_map_camera().get_map_offset().x
		if offset.x >= cursor_pos:
			offset.x -= ceili(16 + size.x)


func select_item(_item: MapMenuItem) -> void:
	HelpPopupController.shrink()


func set_current_item_node(item: HelpContainer) -> void:
	_current_item_index = item.get_index()


func get_current_item_node() -> MapMenuItem:
	_current_item_index %= len(%Items.get_children())
	return %Items.get_child(_current_item_index)
