extends Control

const _DURATION: float = 5.0 / 60
const _HELP_POPUP = preload("res://ui/help_popup/help_popup.gd")

var _active: bool = false:
	set(value):
		_active = value
		get_tree().paused = _active
var _busy: bool = false
var _current_container: HelpContainer
var _current_page: int = 0:
	set(value):
		_current_page = posmod(value, _all_pages.size())
var _all_pages: Array[Array]:
	set(value):
		_all_pages = value
		_current_page = 0
		# Adding every node from each page to the popup node.
		var old_size: Vector2 = _get_popup_node().size
		var old_position: Vector2 = _default_position()
		await _get_popup_node().clear_nodes()
		_get_popup_node().add_nodes(_all_pages)
		var new_size: Vector2 = _get_nodes_size(_get_current_nodes())
		var bottom_bound: float = _position.y + new_size.y + _current_container.size.y
		var above_bottom: bool = bottom_bound >= Utilities.get_screen_size().y
		_position.y += -new_size.y if above_bottom else _current_container.size.y
		if new_size.x / 2 + _position.x > Utilities.get_screen_size().x:
			_position.x = Utilities.get_screen_size().x - new_size.x / 2
		elif _position.x < new_size.x / 2:
			_position.x = new_size.x / 2
		if _position != _default_position():
			if not _get_popup_node().visible:
				await _expand(_get_current_nodes(), _position)
			else:
				await _resize(new_size, _position, old_size, old_position)
		_get_popup_node().set_nodes(_get_current_nodes())
var _position: Vector2


func _init() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED


func _ready() -> void:
	Engine.is_editor_hint()
	if Utilities.is_running_project():
		_get_popup_node().visible = false
		process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		queue_free()


func _input(event: InputEvent) -> void:
	if _get_popup_node().visible:
		if event.is_action_pressed("back"):
			shrink()
			AudioPlayer.play_sound_effect(preload("res://audio/sfx/help_close.ogg"))
		elif event.is_action_pressed("up", true) and not Input.is_action_pressed("down"):
			_move_popup("top")
		elif event.is_action_pressed("down", true):
			_move_popup("bottom")
		elif event.is_action_pressed("left", true) and not Input.is_action_pressed("right"):
			_move_popup("left")
		elif event.is_action_pressed("right", true):
			_move_popup("right")
		elif event.is_action_pressed("previous"):
			_move_page(-1)
		elif event.is_action_pressed("next"):
			_move_page(1)
		get_tree().root.set_input_as_handled()


func set_help_nodes(pages: Array[Array], pos: Vector2, new_container: HelpContainer) -> void:
	if not _busy:
		_current_container = new_container
		_position = pos
		_all_pages = pages


func shrink() -> void:
	if is_idle():
		await _resize(Vector2i(0, 0))
		_get_popup_node().visible = false
		_active = false


func is_active() -> bool:
	return _active


func is_idle() -> bool:
	return is_active() and not _busy


func create_text_node(description_text: String) -> RichTextLabel:
	var description := RichTextLabel.new()
	description.autowrap_mode = TextServer.AUTOWRAP_OFF
	description.text = description_text
	description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	description.fit_content = true
	description.scroll_active = false
	description.bbcode_enabled = true
	if size.x > Utilities.get_screen_size().x:
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		size.x = Utilities.get_screen_size().x
	return description


func _get_popup_node() -> _HELP_POPUP:
	var path := NodePath("%s/HelpPopup" % MapController.get_ui().get_path())
	return get_node(path) if has_node(path) else _HELP_POPUP.new()


func _get_nodes_size(nodes: Array[Control]) -> Vector2i:
	return _get_popup_node().get_nodes_size(nodes)


func _expand(nodes: Array[Control], pos: Vector2) -> void:
	_active = true
	_get_popup_node().visible = true
	await _resize(_get_nodes_size(nodes), pos, Vector2(), pos)


func _resize(
	new_size: Vector2,
	pos: Vector2 = _default_position(),
	init_size: Vector2 = _get_popup_node().size,
	init_position: Vector2 = _default_position()
) -> void:
	_busy = true
	_set_node_size(init_size)
	_set_popup_position(init_position)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_method(_set_node_size, init_size, new_size, _DURATION)
	tween.tween_method(_set_popup_position, init_position, pos, _DURATION)
	_get_popup_node().display_contents(false)
	await tween.finished
	_get_popup_node().display_contents(true)
	_get_popup_node().size = new_size
	_busy = false


func _default_position() -> Vector2:
	return _get_popup_node().position + Vector2(_get_popup_node().size.x / 2, 0)


func _move_popup(direction: String) -> void:
	var path: NodePath = _current_container.get("focus_neighbor_%s" % direction)
	if _current_container.has_node(path):
		(_current_container.get_node(path) as HelpContainer).set_as_current_help_container()
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_TICK_V)


func _set_popup_position(new_pos: Vector2) -> void:
	new_pos -= Vector2(_get_popup_node().size.x / 2, 0)
	_get_popup_node().position = new_pos


func _set_node_size(new_node_size: Vector2) -> void:
	_get_popup_node().size = new_node_size


func _get_current_nodes() -> Array[Control]:
	var nodes: Array[Control] = []
	nodes.assign(_all_pages[_current_page])
	return nodes


func _move_page(offset: int) -> void:
	_current_page += offset
	_get_popup_node().set_nodes(_get_current_nodes())
