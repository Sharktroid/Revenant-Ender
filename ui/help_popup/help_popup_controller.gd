extends Control

const DURATION: float = 5.0 / 60
const BORDER := Vector2i(4, 7)
const TILE_SIZE: int = 32
const _HELP_POPUP = preload("res://ui/help_popup/help_popup.gd")

var _active: bool = false
var _busy: bool = false
var _current_container: HelpContainer

var _current_text: String
var _current_table: Array[String]
var _current_table_cols: int


func _ready() -> void:
	if Utilities.is_running_project():
		get_popup_node().visible = false
	else:
		queue_free()


func receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
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


func display_text(
	text: String,
	pos: Vector2,
	new_container: HelpContainer,
	table: Array[String] = [],
	table_cols: int = 1
) -> void:
	if not _busy:
		var new_size: Vector2 = _get_node_size(text, table, table_cols)
		var bottom_bound: float = pos.y + new_size.y + new_container.size.y
		var above_bottom: bool = bottom_bound >= Utilities.get_screen_size().y
		pos.y += -new_size.y if above_bottom else new_container.size.y
		if new_size.x / 2 + pos.x > Utilities.get_screen_size().x:
			pos.x = Utilities.get_screen_size().x - new_size.x / 2
		elif pos.x < new_size.x / 2:
			pos.x = new_size.x / 2
		if pos != _default_position():
			if not get_popup_node().visible:
				await _expand(text, table, table_cols, pos)
			else:
				await _resize(new_size, pos, get_popup_node().size)
			_current_table = table
			_current_table_cols = table_cols
			_current_text = text
			get_popup_node().set_table(table, table_cols)
			get_popup_node().set_description(text)
			_current_container = new_container


func shrink() -> void:
	if is_idle():
		await _resize(Vector2i(0, 0))
		get_popup_node().visible = false
		_active = false
		GameController.remove_from_input_stack()


func is_active() -> bool:
	return _active


func is_idle() -> bool:
	return is_active() and not _busy


func get_popup_node() -> _HELP_POPUP:
	var path := NodePath("%s/HelpPopup" % MapController.get_ui().get_path())
	return get_node(path) if has_node(path) else _HELP_POPUP.new()


func _get_node_size(new_text: String, new_table: Array[String], new_table_cols: int) -> Vector2i:
	get_popup_node().set_table(new_table, new_table_cols)
	get_popup_node().set_description(new_text)
	var node_size: Vector2i = get_popup_node().size
	get_popup_node().set_table(_current_table, _current_table_cols)
	get_popup_node().set_description(_current_text)
	return node_size


func _expand(text: String, table: Array[String], table_cols: int, pos: Vector2) -> void:
	_active = true
	get_popup_node().visible = true
	await _resize(_get_node_size(text, table, table_cols), pos, Vector2(), pos)


func _resize(
	new_size: Vector2,
	pos: Vector2 = _default_position(),
	init_size: Vector2 = get_popup_node().size,
	init_position: Vector2 = _default_position()
) -> void:
	_busy = true
	_set_node_size(init_size)
	_set_popup_position(init_position)
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_method(_set_node_size, init_size, new_size, DURATION)
	tween.tween_method(_set_popup_position, init_position, pos, DURATION)
	get_popup_node().display_contents(false)
	await tween.finished
	get_popup_node().display_contents(true)
	get_popup_node().size = new_size
	_busy = false


func _default_position() -> Vector2:
	return get_popup_node().position + Vector2(get_popup_node().size.x / 2, 0)


func _move_popup(direction: String) -> void:
	var path: NodePath = _current_container.get("focus_neighbor_%s" % direction)
	if _current_container.has_node(path):
		(_current_container.get_node(path) as HelpContainer).set_as_current_help_container()
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_TICK)


func _set_popup_position(new_pos: Vector2) -> void:
	new_pos -= Vector2(get_popup_node().size.x / 2, 0)
	get_popup_node().position = new_pos


func _set_node_size(new_node_size: Vector2) -> void:
	get_popup_node().size = new_node_size
