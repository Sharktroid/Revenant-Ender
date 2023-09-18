extends Control

const MIN_SPEED = 15
const MAX_DURATION = 5

var _active: bool = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and is_active():
		shrink()
		accept_event()


func display_text(text: String, pos: Vector2, v_size: int) -> void:
	get_popup_node().custom_minimum_size = Vector2()
	get_popup_node().text = text
	var visiblity: bool = get_popup_node().visible
	get_popup_node().visible = !visiblity
	get_popup_node().visible = visiblity
	var popup_size: Vector2i = get_popup_node().size
	if v_size + pos.y + popup_size.y > GenVars.get_screen_size().y:
		pos.y -= popup_size.y
	else:
		pos.y += v_size
	pos.x = clampf(pos.x, float(popup_size.x)/2, GenVars.get_screen_size().x - float(popup_size.x)/2)
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
	var max_size: Vector2 = get_popup_node().custom_minimum_size
	get_popup_node().text = ""
	var min_size: Vector2 = Vector2(41, 0)
	get_popup_node().custom_minimum_size = min_size
	var starting_ticks: int = Engine.get_physics_frames()
	var get_weight: Callable = func(): return _get_weight(starting_ticks, (max_size - min_size))
	while get_weight.call() < 1:
		await get_popup_node().get_tree().process_frame
		get_popup_node().custom_minimum_size = max_size.lerp(min_size, get_weight.call())
	get_popup_node().custom_minimum_size = min_size
	get_popup_node().visible = false
	_active = false


func is_active() -> bool:
	return _active


func get_popup_node() -> Label:
	return MapController.get_ui().get_node("Help Popup")


func _expand(text: String) -> void:
	_active = true
	var min_size: Vector2 = get_popup_node().size
	get_popup_node().text = text
	get_popup_node().visible = true
	var max_size: Vector2 = get_popup_node().size
	get_popup_node().text = ""
	var starting_ticks: int = Engine.get_physics_frames()
	var get_weight: Callable = func(): return _get_weight(starting_ticks, (max_size - min_size))
	while get_weight.call() < 1:
		await get_popup_node().get_tree().process_frame
		get_popup_node().custom_minimum_size = min_size.lerp(max_size, get_weight.call())
	get_popup_node().custom_minimum_size = max_size


func _get_weight(starting_ticks: int, difference: Vector2i) -> float:
	var max_pixels: float = difference[difference.max_axis_index()]
	var duration: float = min(MAX_DURATION, max_pixels/MIN_SPEED)
	return float(Engine.get_physics_frames() - starting_ticks)/duration

