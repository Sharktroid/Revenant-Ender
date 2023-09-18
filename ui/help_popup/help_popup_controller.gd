extends Control

const MIN_SPEED = 15
const MAX_DURATION = 5

var _active: bool = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and is_active():
		shrink()
		accept_event()


func display_text(text: String, pos: Vector2) -> void:
	var anchors: Vector2 = pos/Vector2(GenVars.get_screen_size())
	get_popup_node().anchor_left = anchors.x
	get_popup_node().anchor_right = anchors.x
	get_popup_node().anchor_top = anchors.y
	get_popup_node().anchor_bottom = anchors.y
	if not get_popup_node().visible:
		await _expand(text)
	get_popup_node().custom_minimum_size = Vector2()
	get_popup_node().text = text


func shrink() -> void:
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


func _expand(text: String) -> void:
	_active = true
	get_popup_node().visible = true
	await _resize(get_node_size(text), Vector2())


func _resize(new_size: Vector2, init_size: Vector2 = get_popup_node().size) -> void:
	print_debug(init_size)
	var starting_ticks: int = Engine.get_physics_frames()
	var get_weight: Callable = func(): return _get_weight(starting_ticks, (new_size - init_size))
	while get_weight.call() < 1:
		await get_popup_node().get_tree().process_frame
		get_popup_node().custom_minimum_size = init_size.lerp(new_size, get_weight.call())
	get_popup_node().custom_minimum_size = new_size


func _get_weight(starting_ticks: int, difference: Vector2i) -> float:
	var max_pixels: float = abs(difference[difference.max_axis_index()])
	var duration: float = min(MAX_DURATION, max_pixels/MIN_SPEED)
	return float(Engine.get_physics_frames() - starting_ticks)/duration

