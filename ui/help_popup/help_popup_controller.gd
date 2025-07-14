extends Control

const _DURATION: float = 5.0 / 60
const _HELP_POPUP = preload("res://ui/help_popup/help_popup.gd")

var _active: bool = false
var _busy: bool = false
var _current_container: HelpContainer
var _current_text: String
var _current_table: Table


func _init() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func _ready() -> void:
	Engine.is_editor_hint()
	if Utilities.is_running_project():
		_get_popup_node().visible = false
		process_mode = Node.PROCESS_MODE_INHERIT
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
		get_tree().root.set_input_as_handled()


func display_text(
	text: String,
	pos: Vector2,
	new_container: HelpContainer,
	table: Table = null
) -> void:
	if not _busy:
		var new_size: Vector2 = await _get_node_size(text, table)
		var bottom_bound: float = pos.y + new_size.y + new_container.size.y
		var above_bottom: bool = bottom_bound >= Utilities.get_screen_size().y
		pos.y += -new_size.y if above_bottom else new_container.size.y
		if new_size.x / 2 + pos.x > Utilities.get_screen_size().x:
			pos.x = Utilities.get_screen_size().x - new_size.x / 2
		elif pos.x < new_size.x / 2:
			pos.x = new_size.x / 2
		if pos != _default_position():
			if not _get_popup_node().visible:
				await _expand(text, table, pos)
			else:
				await _resize(new_size, pos, _get_popup_node().size)
			_current_table = table
			_current_text = text
			await _get_popup_node().clear_nodes()
			_get_popup_node().add_table(table)
			_get_popup_node().add_description(text)
			_current_container = new_container


func shrink() -> void:
	if is_idle():
		await _resize(Vector2i(0, 0))
		_get_popup_node().visible = false
		_active = false


func is_active() -> bool:
	return _active


func is_idle() -> bool:
	return is_active() and not _busy


func _get_popup_node() -> _HELP_POPUP:
	var path := NodePath("%s/HelpPopup" % MapController.get_ui().get_path())
	return get_node(path) if has_node(path) else _HELP_POPUP.new()


func _get_node_size(new_text: String, new_table: Table) -> Vector2i:
	await _get_popup_node().clear_nodes()
	_get_popup_node().add_table(new_table)
	_get_popup_node().add_description(new_text)
	var node_size: Vector2i = _get_popup_node().size
	await _get_popup_node().clear_nodes()
	_get_popup_node().add_table(_current_table)
	_get_popup_node().add_description(_current_text)
	return node_size


func _expand(text: String, table: Table, pos: Vector2) -> void:
	_active = true
	_get_popup_node().visible = true
	await _resize(await _get_node_size(text, table), pos, Vector2(), pos)


func _resize(
	new_size: Vector2,
	pos: Vector2 = _default_position(),
	init_size: Vector2 = _get_popup_node().size,
	init_position: Vector2 = _default_position()
) -> void:
	_busy = true
	_set_node_size(init_size)
	_set_popup_position(init_position)
	var tween: Tween = get_tree().create_tween()
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
