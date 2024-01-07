extends Control

const DURATION: float = 5.0/60
const BORDER := Vector2i(4, 7)
const TILE_SIZE: int = 32

var _active: bool = false
var _busy: bool = false


func _ready() -> void:
	get_popup_node().visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and is_active():
		shrink()
		accept_event()


func display_text(text: String, pos: Vector2) -> void:
	if not _busy and (pos != _default_position() or text != get_popup_node().text):
		var old_text: String = get_popup_node().text
		get_popup_node().text = ""
		if not get_popup_node().visible:
			await _expand(text, pos)
		else:
			await _resize(get_node_size(text), pos, get_node_size(old_text))
		get_popup_node().text = text


func shrink() -> void:
	if not _busy:
		get_popup_node().text = ""
		var new_size: Vector2 = Vector2(41, 0)
		await _resize(new_size)
		get_popup_node().visible = false
		_active = false


func is_active() -> bool:
	return _active


func get_popup_node() -> RichTextLabel:
	if MapController.get_ui().has_node("Help Popup"):
		return MapController.get_ui().get_node("Help Popup")
	else:
		return RichTextLabel.new()


func get_node_size(text: String) -> Vector2i:
	var old_size: Vector2 = get_popup_node().size
	var string: String = get_popup_node().text
	get_popup_node().autowrap_mode = TextServer.AUTOWRAP_OFF
	get_popup_node().text = text
	get_popup_node().reset_size()
	var node_size: Vector2i = get_popup_node().size
	if node_size > Utilities.get_screen_size():
		get_popup_node().autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	get_popup_node().reset_size()
	get_popup_node().text = string
	get_popup_node().size = old_size
#	node_size -= BORDER
#	node_size = Vector2i((Vector2(node_size)/TILE_SIZE).round()) * TILE_SIZE
#	node_size += BORDER
	return node_size


func _expand(text: String, pos: Vector2) -> void:
	_active = true
	get_popup_node().visible = true
	await _resize(get_node_size(text), pos, Vector2(), pos)


func _resize(new_size: Vector2, pos: Vector2 = _default_position(),
		init_size: Vector2 = get_popup_node().size,
		init_position: Vector2 = _default_position()) -> void:
	var set_pos: Callable = func(new_pos: Vector2) -> void:
		new_pos -= Vector2(get_popup_node().size.x/2, 0)
		get_popup_node().position = new_pos.clamp(Vector2(),
				Vector2(Utilities.get_screen_size()) - get_popup_node().size)
	var set_node_size: Callable = func(new_node_size: Vector2) -> void:
		get_popup_node().size = new_node_size.clamp(Vector2(), Utilities.get_screen_size())
	_busy = true
	set_node_size.call(init_size)
	set_pos.call(init_position)
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_method(set_node_size, init_size, new_size, DURATION)
	tween.tween_method(set_pos, init_position, pos, DURATION)
	await tween.finished
	_busy = false


func _default_position() -> Vector2:
	return get_popup_node().position + Vector2(get_popup_node().size.x/2, 0)

