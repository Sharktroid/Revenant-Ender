class_name Dialogue
extends Control

const CHARS_PER_SECOND: int = 300
const FULL_SCROLL_SPEED: float = 0.25
const LINE_COUNT: int = 5
const SHIFT_DURATION: int = 8 # In ticks
const TEXTBOX_HEIGHT: int = 94
const PORTRAIT_WIDTH: int = 96

enum positions {OUTSIDELEFT = -80, FARLEFT = 0, MIDLEFT = 80, CLOSELEFT = 160,
		CLOSERIGHT = 256, MIDRIGHT = 336, FARRIGHT = 416, OUTSIDERIGHT = 512}
enum directions {LEFT, RIGHT}

@onready var _top_bubble_point: TextureRect = $"Top Bubble Point"
@onready var _bottom_bubble_point: TextureRect = $"Bottom Bubble Point"
var _portraits: Dictionary = {}
var _top_speaker: Unit
var _bottom_speaker: Unit
var _skipping: bool = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_skipping = true
		var portraits: Array = _portraits.keys()
		var last_portrait: Unit = portraits.pop_back()
		for portrait: Unit in portraits:
			remove_portrait(portrait)
		await remove_portrait(last_portrait)


func set_top_text(string: String) -> void:
	if _skipping:
		return
	await _set_text_base(string, %"Top Textbox" as RichTextLabel,
			_portraits.get(_top_speaker, Portrait.new()) as Portrait)


func set_bottom_text(string: String) -> void:
	if _skipping:
		return
	await _set_text_base(string, %"Bottom Textbox" as RichTextLabel,
			_portraits.get(_bottom_speaker, Portrait.new()) as Portrait)


func clear_top() -> void:
	await _clear(%"Top Textbox" as RichTextLabel)


func clear_bottom() -> void:
	await _clear(%"Bottom Textbox" as RichTextLabel)


func set_top_speaker(new_speaker: Unit) -> void:
	if _skipping:
		return
	_top_speaker = new_speaker
	if new_speaker in _portraits.keys():
		_configure_point(_top_bubble_point,
				roundi(_get_portrait(new_speaker as Unit).position.x))
	await clear_top()
	await _set_speaker(%"Top Name" as RichTextLabel, new_speaker as Unit)


func set_bottom_speaker(new_speaker: Unit) -> void:
	if _skipping:
		return
	_bottom_speaker = new_speaker
	if new_speaker in _portraits.keys():
		_configure_point(_bottom_bubble_point,
				roundi(_get_portrait(new_speaker as Unit).position.x))
	await clear_bottom()
	await _set_speaker(%"Bottom Name" as RichTextLabel, new_speaker as Unit)


func add_portrait(new_speaker: Unit, portrait_position: positions,
		flip_h: bool = false) -> void:
	if _skipping:
		return
	var portrait: Portrait = new_speaker.get_portrait().duplicate()
	if flip_h:
		portrait.flip()
	portrait.position = Vector2i(portrait_position, 20)
	portrait.modulate.v = 0
	$Portraits.add_child(portrait)
	_portraits[new_speaker] = portrait
	for i in SHIFT_DURATION:
		portrait.modulate.v = remap(i, 0, SHIFT_DURATION, 0, 1)
		await get_tree().physics_frame
	portrait.modulate.v = 1


func remove_portrait(old_speaker: Unit) -> void:
	var portrait := Portrait.new()
	if is_instance_valid(_portraits.get(old_speaker)):
		portrait = _portraits.get(old_speaker, Portrait.new())
		print_debug(portrait)
	portrait.modulate.v = 1
	for i in SHIFT_DURATION:
		portrait.modulate.v = remap(i, 0, SHIFT_DURATION, 1, 0)
		await get_tree().physics_frame
		if not is_instance_valid(portrait):
			return
	portrait.queue_free()


func show_top_textbox(box_position: positions) -> void:
	await _show_textbox(box_position, $MarginContainerTop as MarginContainer,
			false, _top_bubble_point)


func show_bottom_textbox(box_position: positions) -> void:
	await _show_textbox(box_position, $MarginContainerBottom as MarginContainer,
			true, _bottom_bubble_point)


func hide_top_textbox() -> void:
	await _hide_textbox($MarginContainerTop as MarginContainer, false, _top_bubble_point)


func hide_bottom_textbox() -> void:
	await _hide_textbox($MarginContainerBottom as MarginContainer, true, _bottom_bubble_point)


func _show_textbox(box_position: positions, textbox: MarginContainer, align_bottom: bool,
		bubble_point: TextureRect) -> void:
	if _skipping:
		return
	textbox.visible = true
	_configure_point(bubble_point, box_position)
	await _resize_textbox(textbox, align_bottom, bubble_point, textbox.custom_minimum_size,
			Vector2i(GenVars.get_screen_size().x, TEXTBOX_HEIGHT))
	textbox.position.x = 0
	if align_bottom:
		textbox.position.y = (GenVars.get_screen_size().y - textbox.size.y)
		bubble_point.position.y = textbox.position.y - bubble_point.size.y + 2
	else:
		bubble_point.position.y = textbox.size.y - 2


func _hide_textbox(textbox: MarginContainer, align_bottom: bool,
		bubble_point: TextureRect) -> void:
	await _resize_textbox(textbox, align_bottom, bubble_point,
			Vector2i(GenVars.get_screen_size().x, TEXTBOX_HEIGHT), textbox.custom_minimum_size)
	textbox.visible = false
	bubble_point.visible = false


func _resize_textbox(textbox: MarginContainer, align_bottom: bool,
		bubble_point: TextureRect, starting_size: Vector2,
		target_size: Vector2i) -> void:
	var target_x: float = bubble_point.position.x + bubble_point.size.x/2
	textbox.anchor_left = target_x/GenVars.get_screen_size().x
	textbox.anchor_right = textbox.anchor_left
	textbox.size = starting_size
	for i in SHIFT_DURATION:
		textbox.size = starting_size.lerp(target_size, inverse_lerp(0, SHIFT_DURATION, i))
		textbox.size = textbox.size.snapped(Vector2i(2, 2))
		textbox.position.x = clamp(target_x - textbox.size.x/2,
				0, GenVars.get_screen_size().x - textbox.size.x)
		if align_bottom:
			textbox.position.y = (GenVars.get_screen_size().y - textbox.size.y)
			bubble_point.position.y = textbox.position.y - bubble_point.size.y + 2
		else:
			bubble_point.position.y = textbox.size.y - 2
		await get_tree().physics_frame
	textbox.size = target_size


func _set_text_base(string: String, label: RichTextLabel, portrait: Portrait) -> void:
	if _skipping:
		return
	portrait.set_talking(true)
	label.text += string
	label.visible_ratio = 0
	if string.length() == 0:
		label.visible_ratio = 1
	label.visible_characters = label.text.length() - string.length()
	var autoscroll: bool = false
	var timer: int = 0
	#region Gradually displays text
	while label.visible_ratio < 1:
		if not autoscroll:
			await get_tree().physics_frame
		if _skipping:
			return
		elif Input.is_action_just_pressed("ui_accept"):
			autoscroll = true
			await get_tree().physics_frame
		if timer > 0:
			timer -= 1
		else:
			var next_visible_chars: int = (label.visible_characters +
					roundi(CHARS_PER_SECOND * GenVars.get_frame_delta()))
			while (label.visible_characters < next_visible_chars and label.visible_ratio < 1):
				label.visible_characters += 1
				# Scrolls when overflowing
				if label.get_line_count() > LINE_COUNT + (label.position.y/-_get_line_height()):
					label.visible_characters -= 1
					autoscroll = false
					await _scroll(label)
					break
				# Delays for punctuation
				elif label.text[label.visible_characters - 1] in [",", ".", ";", ":"]:
					if not autoscroll:
						timer = roundi(1000.0 / CHARS_PER_SECOND)
					break
	label.visible_ratio = 1
	#endregion
	portrait.set_talking(false)
	while not (Input.is_action_just_pressed("ui_accept") or
			Input.is_action_just_pressed("ui_cancel")):
		await get_tree().physics_frame


func _scroll(label: RichTextLabel) -> void:
	if _skipping:
		return
	var new_y: int = roundi(label.position.y - _get_line_height())
	while roundi(label.position.y) > new_y:
		label.position.y -= (_get_line_height() * LINE_COUNT)/60.0 / FULL_SCROLL_SPEED
		await get_tree().physics_frame
	label.position.y = roundi(label.position.y)


func _clear(label: RichTextLabel) -> void:
	for i in LINE_COUNT:
		await _scroll(label)
	label.text = ""
	label.position.y = 0


func _get_line_height() -> int:
	return 16 + %"Top Textbox".get_theme_constant("line_separation")


func _set_speaker(name_label: RichTextLabel, new_speaker: Unit) -> void:
	if _skipping:
		return
	for i in ceili(float(SHIFT_DURATION) / 2):
		name_label.visible_ratio = remap(i, 0, ceili(float(SHIFT_DURATION) / 2), 1, 0)
		await get_tree().physics_frame
	name_label.visible_ratio = 0
	name_label.text = new_speaker.unit_name
	for i in floori(float(SHIFT_DURATION) / 2):
		name_label.visible_ratio = remap(i, 0, floori(float(SHIFT_DURATION) / 2), 0, 1)
		await get_tree().physics_frame
	name_label.visible_ratio = 1


func _configure_point(bubble_point: TextureRect, point_x: int) -> void:
	bubble_point.visible = true
	if point_x < (float(GenVars.get_screen_size().y)/2):
		bubble_point.flip_h = true
		bubble_point.position.x = point_x + PORTRAIT_WIDTH
	else:
		bubble_point.flip_h = false
		bubble_point.position.x = point_x - bubble_point.size.x


func _get_portrait(unit: Unit) -> Portrait:
	return _portraits[unit]
