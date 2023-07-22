class_name MapMenu
extends NinePatchRect

enum types {SACRED_STONES, BINDING_BLADE}

var item_keys: Array[String]
var parent_menu: MapMenu
var _start_offset: int
var _end_offset: int
var _current_button_index: int = 0
var _debug_display: Polygon2D


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
			var button: Button = $"Base Button".duplicate()
			if items[item] == null:
				button.text = item
			else:
				button.text = "%s: %s" % [item, items[item]]
			button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			button.item = item
			button.parent_menu = self
			new_size.y += 16
			$Items.add_child(button)
			new_size.x = max(new_size.x, button.size.x * scale.x + 4)
		$Items.size = new_size
		size = $Items.size + Vector2(9, 9)
		set_map_position((GenVars.cursor as Cursor).get_true_pos() + map_offset + Vector2i(16, -16))
		$"Base Button".queue_free()
		grab_focus()


func _process(_delta: float) -> void:
	if has_focus():
		if not(_debug_display in _get_current_button().get_children()):
			if not _debug_display:
				_debug_display = Polygon2D.new()
				_debug_display.polygon = [Vector2i(), Vector2i(0, 16), Vector2i(16, 16), Vector2i(16, 0)]
			else:
				_debug_display.get_parent().remove_child(_debug_display)
			_get_current_button().add_child(_debug_display)

	else:
		if is_instance_valid(_debug_display):
			_debug_display.queue_free()


func _has_point(_point: Vector2) -> bool:
	return true


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		_current_button_index -= 1

	elif event.is_action_pressed("ui_down"):
		_current_button_index += 1

	if event.is_action_pressed("ui_accept"):
		select_item(_get_current_button().item)
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
		new_position.x -= ceil((16 + size.x))
	position = GenFunc.clamp_vector(new_position, Vector2i(), GenVars.get_screen_size() - Vector2i(size))


func select_item(_item: String) -> void:
	pass


func _get_current_button() -> Button:
	_current_button_index %= len($Items.get_children())
	return $Items.get_child(_current_button_index)
