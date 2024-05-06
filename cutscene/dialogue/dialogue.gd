class_name Dialogue
extends Control

const CHARS_PER_SECOND: int = 300
const FULL_SCROLL_SPEED: float = 0.25
const LINE_COUNT: int = 5
const SHIFT_DURATION: float = 8.0/60 # In seconds
const TEXTBOX_HEIGHT: int = 94
const PORTRAIT_WIDTH: int = 96

enum positions {OUTSIDE_LEFT = -80, FAR_LEFT = 0, MID_LEFT = 80, CLOSE_LEFT = 160,
		CLOSE_RIGHT = 256, MID_RIGHT = 336, FAR_RIGHT = 416, OUTSIDE_RIGHT = 512}
enum directions {LEFT, RIGHT}

@onready var _top_bubble_point := $"Top Bubble Point" as TextureRect
@onready var _bottom_bubble_point := $"Bottom Bubble Point" as TextureRect
@onready var _top_textbox := %"Top Textbox" as RichTextLabel
@onready var _bottom_textbox := %"Bottom Textbox" as RichTextLabel
var _portraits: Dictionary = {}
var _top_speaker: Unit
var _bottom_speaker: Unit
var _skipping: bool = false


func receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var portraits := _portraits.keys() as Array[Unit]
		var last_portrait: Unit = portraits.pop_back()
		for portrait: Unit in portraits:
			remove_portrait(portrait)
		await remove_portrait(last_portrait)
		hide_top_textbox()
		await hide_bottom_textbox()
		_skipping = true


func set_top_text(string: String) -> void:
	if not _skipping:
		await _set_text_base(string, _top_textbox,
				_portraits.get(_top_speaker, Portrait.new()))


func set_bottom_text(string: String) -> void:
	if not _skipping:
		await _set_text_base(string, _bottom_textbox,
				_portraits.get(_bottom_speaker, Portrait.new()))


func clear_top() -> void:
	await _clear(_top_textbox)


func clear_bottom() -> void:
	await _clear(_bottom_textbox)


func set_top_speaker(new_speaker: Unit) -> void:
	if not _skipping:
		_top_speaker = new_speaker
		if new_speaker in _portraits.keys():
			_configure_point(_top_bubble_point,
					roundi(_get_portrait(new_speaker as Unit).position.x))
		await clear_top()
		await _set_speaker(%"Top Name" as RichTextLabel, new_speaker as Unit)


func set_bottom_speaker(new_speaker: Unit) -> void:
	if not _skipping:
		_bottom_speaker = new_speaker
		if new_speaker in _portraits.keys():
			_configure_point(_bottom_bubble_point,
					roundi(_get_portrait(new_speaker as Unit).position.x))
		await clear_bottom()
		await _set_speaker(%"Bottom Name" as RichTextLabel, new_speaker as Unit)


func add_portrait(new_speaker: Unit, portrait_position: positions,
		flip_h: bool = false) -> void:
	if not _skipping:
		var portrait: Portrait = new_speaker.get_portrait()
		if flip_h:
			portrait.flip()
		portrait.position = Vector2i(portrait_position, 20)
		$Portraits.add_child(portrait)
		_portraits[new_speaker] = portrait
		var tween: Tween = create_tween()
		portrait.modulate.v = 0
		tween.tween_property(portrait, "modulate:v", 1, SHIFT_DURATION)
		await tween.finished


func remove_portrait(old_speaker: Unit) -> void:
	if not _skipping:
		var portrait := Portrait.new()
		if is_instance_valid(_portraits.get(old_speaker)):
			portrait = _portraits.get(old_speaker, Portrait.new())
		var tween: Tween = create_tween()
		tween.tween_property(portrait, "modulate:v", 0, SHIFT_DURATION)
		await tween.finished
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
	if not _skipping:
		textbox.visible = true
		_configure_point(bubble_point, box_position)
		await _resize_textbox(textbox, align_bottom, bubble_point, textbox.custom_minimum_size,
				Vector2i(Utilities.get_screen_size().x, TEXTBOX_HEIGHT))
		textbox.position.x = 0
		if align_bottom:
			textbox.position.y = (Utilities.get_screen_size().y - textbox.size.y)
			bubble_point.position.y = textbox.position.y - bubble_point.size.y + 2
		else:
			bubble_point.position.y = textbox.size.y - 2


func _hide_textbox(textbox: MarginContainer, align_bottom: bool,
		bubble_point: TextureRect) -> void:
	if not _skipping:
		await _resize_textbox(textbox, align_bottom, bubble_point,
				Vector2i(Utilities.get_screen_size().x, TEXTBOX_HEIGHT), textbox.custom_minimum_size)
		textbox.visible = false
		bubble_point.visible = false


func _resize_textbox(textbox: MarginContainer, align_bottom: bool,
		bubble_point: TextureRect, starting_size: Vector2,
		target_size: Vector2) -> void:
	var target_x: float = bubble_point.position.x + bubble_point.size.x/2
	textbox.anchor_left = target_x/Utilities.get_screen_size().x
	textbox.anchor_right = textbox.anchor_left

	var adjust_size: Callable = func(new_size: Vector2) -> void:
		textbox.size = new_size.snapped(Vector2i(2, 2))
		textbox.position.x = clampf(target_x - textbox.size.x/2,
				0, Utilities.get_screen_size().x - textbox.size.x)
		if align_bottom:
			textbox.position.y = (Utilities.get_screen_size().y - textbox.size.y)
			bubble_point.position.y = textbox.position.y - bubble_point.size.y + 2
		else:
			bubble_point.position.y = textbox.size.y - 2

	var tween: Tween = create_tween()
	tween.tween_method(adjust_size, starting_size, target_size, SHIFT_DURATION)
	await tween.finished


func _set_text_base(string: String, label: RichTextLabel, portrait: Portrait) -> void:
	if not _skipping:
		portrait.set_talking(true)
		label.text += string
		label.visible_ratio = 0
		if string.length() == 0:
			label.visible_ratio = 1
		label.visible_characters = label.text.length() - string.length()
		var autoscroll: bool = false
		var timer: int = 0
		#region Gradually displays text
		while label.visible_ratio < 1 and not _skipping:
			if not autoscroll:
				await get_tree().physics_frame
			if Input.is_action_just_pressed("ui_accept"):
				autoscroll = true
				await get_tree().physics_frame # Prevents input from being double read
			if timer > 0:
				timer -= 1
			else:
				var next_visible_chars: int = (label.visible_characters +
						roundi(CHARS_PER_SECOND * get_process_delta_time()))
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
		while not (Input.is_action_just_pressed("ui_accept") or _skipping):
			await get_tree().physics_frame


func _scroll(label: RichTextLabel) -> void:
	if not _skipping:
		var new_y: int = roundi(label.position.y - _get_line_height())
		var tween: Tween = create_tween()
		tween.tween_property(label, "position:y", new_y, FULL_SCROLL_SPEED / LINE_COUNT)
		await tween.finished


func _clear(label: RichTextLabel) -> void:
	for i: int in LINE_COUNT:
		await _scroll(label)
	label.text = ""
	label.position.y = 0


func _get_line_height() -> int:
	return 16 + _top_textbox.get_theme_constant("line_separation")


func _set_speaker(name_label: RichTextLabel, new_speaker: Unit) -> void:
	if not _skipping:
		if name_label.text != "":
			var slide_out: Tween = create_tween()
			slide_out.set_speed_scale(2)
			slide_out.tween_property(name_label, "visible_ratio", 0, SHIFT_DURATION)
			await slide_out.finished
		name_label.text = new_speaker.unit_name
		var slide_in: Tween = create_tween()
		slide_in.set_speed_scale(2)
		slide_in.tween_property(name_label, "visible_ratio", 1, SHIFT_DURATION / 2)
		await slide_in.finished


func _configure_point(bubble_point: TextureRect, point_x: int) -> void:
	bubble_point.visible = true
	bubble_point.flip_h = point_x < (float(Utilities.get_screen_size().y)/2)
	bubble_point.position.x = (
			float(point_x + PORTRAIT_WIDTH) if bubble_point.flip_h
			else point_x - bubble_point.size.x
	)


func _get_portrait(unit: Unit) -> Portrait:
	return _portraits[unit]
