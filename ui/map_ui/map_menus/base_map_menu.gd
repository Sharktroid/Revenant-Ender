class_name MapMenu
extends PanelContainer

enum types {SACRED_STONES, BINDING_BLADE}

var parent_menu: MapMenu

var _current_item_index: int = 0


func _ready() -> void:
	var new_size = Vector2()
	for item in %Items.get_children():
		item.custom_minimum_size.x = new_size.x
	%Items.size = new_size
	size = %Items.size + Vector2(9, 9)
	var map_offset: Vector2i = MapController.get_map_camera().get_map_offset()
	set_map_position(MapController.get_cursor().get_true_pos() + map_offset + Vector2i(16, -16))
	grab_focus()


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


func set_map_position(new_position: Vector2i) -> void:
	if new_position.x >= float(GenVars.get_screen_size().x)/2:
		new_position.x -= ceili(16 + size.x)
	position = new_position.clamp(Vector2i(), GenVars.get_screen_size() - Vector2i(size))


func select_item(_item: MapMenuItem) -> void:
	HelpPopupController.shrink()


func set_current_item_node(item: HelpContainer) -> void:
	_current_item_index = item.get_index()


func get_current_item_node() -> MapMenuItem:
	_current_item_index %= len(%Items.get_children())
	return %Items.get_child(_current_item_index)
