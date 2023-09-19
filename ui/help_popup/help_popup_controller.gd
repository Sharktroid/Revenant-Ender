extends Control

const DURATION = 5

var _active: bool = false
var _busy: bool = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and is_active():
		shrink()
		accept_event()


func display_text(text: String, pos: Vector2) -> void:
	if not _busy and pos != _default_position() and text != get_popup_node().text:
		var old_text: String = get_popup_node().text
		get_popup_node().text = ""
		if not get_popup_node().visible:
			await _expand(text, pos)
		else:
			await _resize(get_node_size(text), pos, get_node_size(old_text))
		get_popup_node().custom_minimum_size = Vector2()
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


func get_popup_node() -> Label:
	return MapController.get_ui().get_node("Help Popup")


func get_node_size(text: String) -> Vector2i:
	var old_size: Vector2 = get_popup_node().custom_minimum_size
	get_popup_node().custom_minimum_size = Vector2()
	var string: String = get_popup_node().text
	get_popup_node().text = text
	var visiblity: bool = get_popup_node().visible
	get_popup_node().visible = !visiblity
	get_popup_node().visible = visiblity
	var node_size: Vector2 = get_popup_node().size
	get_popup_node().text = string
	get_popup_node().custom_minimum_size = old_size
	return node_size


func _expand(text: String, pos: Vector2) -> void:
	_active = true
	get_popup_node().visible = true
	await _resize(get_node_size(text), pos, Vector2(), pos)


func _resize(new_size: Vector2, pos: Vector2 = _default_position(),
		init_size: Vector2 = get_popup_node().size, init_position: Vector2 = _default_position()) -> void:
	var init_anchors: Vector2 = init_position/Vector2(GenVars.get_screen_size())
	var final_anchors: Vector2 = pos/Vector2(GenVars.get_screen_size())
	var set_anchors: Callable = func(anchors: Vector2):
		get_popup_node().anchor_left = anchors.x
		get_popup_node().anchor_right = anchors.x
		get_popup_node().anchor_top = anchors.y
		get_popup_node().anchor_bottom = anchors.y
	var starting_ticks: int = Engine.get_physics_frames()
	var get_weight: Callable = func(): return _get_weight(starting_ticks)
	get_popup_node().custom_minimum_size = init_size
	_busy = true
	while get_weight.call() < 1:
		await get_popup_node().get_tree().process_frame
		set_anchors.call(init_anchors.lerp(final_anchors, get_weight.call()))
		get_popup_node().custom_minimum_size = init_size.lerp(new_size, get_weight.call())
	set_anchors.call(final_anchors)
	get_popup_node().custom_minimum_size = new_size
	_busy = false


func _default_position() -> Vector2:
	var anchors: Vector2 = Vector2(get_popup_node().anchor_left, get_popup_node().anchor_top)
	return anchors * Vector2(GenVars.get_screen_size())


func _get_weight(starting_ticks: int) -> float:
	return float(Engine.get_physics_frames() - starting_ticks)/DURATION

