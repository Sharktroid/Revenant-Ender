class_name MapMenu
extends PanelContainer

enum types {SACRED_STONES, BINDING_BLADE}

var item_keys: Array[String]
var parent_menu: MapMenu
var _start_offset: int
var _end_offset: int
var _current_item_index: int = 0


func _enter_tree() -> void:
	_start_offset = 4
	_end_offset = 5


func _ready() -> void:
	var new_size = Vector2()
	var map_offset: Vector2i = (GenVars.map_camera as MapCamera).map_offset
	var items = get_items()
	if len(items) == 0:
		close()
	else:
		for item in items:
			var item_node: Control = %"Base Item".duplicate()
			if items[item] == null:
				item_node.text = item
			elif items[item] is Callable:
				item_node.update_text = func(): item_node.text = "%s: %s" % [item, items[item].call()]
				item_node.update_text.call()
			else:
				item_node.text = "%s: %s" % [item, items[item]]
			item_node.name = item
			item_node.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			item_node.item = item
			item_node.parent_menu = self
			new_size.y += 16
			%Items.add_child(item_node)
			new_size.x = max(new_size.x, item_node.size.x * scale.x + 4)
		for item in %Items.get_children():
			(item as Label).custom_minimum_size.x = new_size.x
		%Items.size = new_size
		size = %Items.size + Vector2(9, 9)
		set_map_position((GenVars.cursor as Cursor).get_true_pos() + map_offset + Vector2i(16, -16))
		%"Base Item".queue_free()
		grab_focus()


func _has_point(_point: Vector2) -> bool:
	return true


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		_current_item_index -= 1

	elif event.is_action_pressed("down"):
		_current_item_index += 1

	if event.is_action_pressed("ui_accept"):
		select_item(get_current_item_node().item)
		accept_event()

	elif event.is_action_pressed("ui_cancel"):
		close()


func get_items() -> Dictionary:
	var items := {}
	for item in item_keys:
		items[item] = null
	return items


func close() -> void:
	# Closes the menu
	queue_free()
	GenVars.map_controller.grab_focus()


func set_map_position(new_position: Vector2i) -> void:
	if new_position.x >= float(GenVars.get_screen_size().x)/2:
		new_position.x -= ceili(16 + size.x)
	position = new_position.clamp(Vector2i(), GenVars.get_screen_size() - Vector2i(size))


func select_item(_item: String) -> void:
	get_current_item_node().update_text.call()


func set_current_item_node(item: Label) -> void:
	_current_item_index = item.get_index()


func get_current_item_node() -> Label:
	_current_item_index %= len(%Items.get_children())
	return %Items.get_child(_current_item_index)
