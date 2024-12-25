class_name MapMenu
extends PanelContainer

var _offset: Vector2:
	set(value):
		_offset = value
		_update_position()
var _parent_menu: MapMenu
var _current_item_index: int = 0:
	set(value):
		var different: bool = value != _current_item_index
		if different:
			get_current_item_node().selected = false
		_current_item_index = value
		if different:
			get_current_item_node().selected = true
	get:
		if _get_visible_children().is_empty():
			return 0
		else:
			return posmod(_current_item_index, _get_visible_children().size())
## If true, the menu will move to the left if on the right side of the screen
var _to_center: bool = true


func _enter_tree() -> void:
	_update_position.call_deferred()
	var visible_children: Array[Node] = []
	visible_children.assign(_get_visible_children())
	for index: int in visible_children.size():
		Utilities.set_neighbor_path("top", index, -1, visible_children)
		Utilities.set_neighbor_path("bottom", index, 1, visible_children)


func _exit_tree() -> void:
	if is_instance_valid(_parent_menu):
		_parent_menu.visible = true


func _input(event: InputEvent) -> void:
	if not HelpPopupController.is_active():
		if event.is_action_pressed("up") and not Input.is_action_pressed("down"):
			_current_item_index -= 1
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_TICK_V)

		elif event.is_action_pressed("down"):
			_current_item_index += 1
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_TICK_V)

		if event.is_action_pressed("ui_accept"):
			_play_select_sound_effect(get_current_item_node())
			_select_item(get_current_item_node())

		elif event.is_action_pressed("ui_cancel"):
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)
			queue_free()
		get_tree().root.set_input_as_handled()


func set_current_item_node(item: HelpContainer) -> void:
	_current_item_index = _get_visible_children().find(item)


func get_current_item_node() -> MapMenuItem:
	if not _get_visible_children().is_empty():
		return _get_visible_children()[_current_item_index]
	else:
		return null


func _update_position() -> void:
	reset_size()
	position = _offset.clamp(Vector2i(), Utilities.get_screen_size() - Vector2i(size))
	if (
		_offset.x >= float(Utilities.get_screen_size().x) / 2
		and _to_center
		and _offset.x >= CursorController.screen_position.x
	):
		position.x -= ceili(16 + size.x)


## Called when a [MapMenuItem] is selected.
func _select_item(_item: MapMenuItem) -> void:
	HelpPopupController.shrink()


func _play_select_sound_effect(_item: MapMenuItem) -> void:
	AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_SELECT)


func _get_visible_children() -> Array[MapMenuItem]:
	var children: Array[MapMenuItem] = []
	children.assign(
		%Items.get_children().filter(func(child: MapMenuItem) -> bool: return child.visible)
	)
	return children


static func _base_instantiate(
	packed_scene: PackedScene, new_offset: Vector2, parent: MapMenu
) -> MapMenu:
	var scene := packed_scene.instantiate() as MapMenu
	scene._offset = new_offset
	scene._parent_menu = parent
	return scene
