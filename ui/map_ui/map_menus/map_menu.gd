class_name MapMenu
extends PanelContainer

var offset: Vector2:
	set(value):
		offset = value
		update_position()
var parent_menu: MapMenu
## If true, the menu will move to the left if on the right side of the screen
var _to_center: bool = true
var _current_item_index: int = 0:
	set(value):
		var different: bool = value != _current_item_index
		if different:
			get_current_item_node().deselect()
		_current_item_index = value
		if different:
			get_current_item_node().select()
	get:
		return posmod(_current_item_index, _get_visible_children().size())


func _enter_tree() -> void:
	update_position.call_deferred()
	var visible_children: Array[Node] = []
	for child: MapMenuItem in _get_visible_children():
		visible_children.append(child)
	for index: int in visible_children.size():
		Utilities.set_neighbor_path("top", index, -1, visible_children)
		Utilities.set_neighbor_path("bottom", index, 1, visible_children)
	GameController.add_to_input_stack(self)


func receive_input(event: InputEvent) -> void:
	if not HelpPopupController.is_active():
		if event.is_action_pressed("up") and not Input.is_action_pressed("down"):
			_current_item_index -= 1
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_TICK)

		elif event.is_action_pressed("down"):
			_current_item_index += 1
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_TICK)

		if event.is_action_pressed("ui_accept"):
			_play_select_sound_effect(get_current_item_node())
			select_item(get_current_item_node())

		elif event.is_action_pressed("ui_cancel"):
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)
			close()


func close() -> void:
	# Closes the menu
	queue_free()
	if parent_menu:
		parent_menu.visible = true


func update_position() -> void:
	reset_size()
	position = offset.clamp(Vector2i(), Utilities.get_screen_size() - Vector2i(size))
	if (
		offset.x >= float(Utilities.get_screen_size().x) / 2
		and _to_center
		and offset.x >= CursorController.screen_position.x
	):
		position.x -= ceili(16 + size.x)


func select_item(_item: MapMenuItem) -> void:
	HelpPopupController.shrink()


func set_current_item_node(item: HelpContainer) -> void:
	_current_item_index = _get_visible_children().find(item)


func get_current_item_node() -> MapMenuItem:
	return (
		_get_visible_children()[_current_item_index] if _get_visible_children().size() > 0 else null
	)


func _play_select_sound_effect(_item: MapMenuItem) -> void:
	AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_SELECT)


func _get_visible_children() -> Array[MapMenuItem]:
	var children: Array[MapMenuItem] = []
	for child: Node in %Items.get_children():
		if (child as MapMenuItem).visible == true:
			children.append(child)
	return children


static func _base_instantiate(
	packed_scene: PackedScene, new_offset: Vector2, parent: MapMenu
) -> MapMenu:
	var scene := packed_scene.instantiate() as MapMenu
	scene.offset = new_offset
	scene.parent_menu = parent
	return scene
