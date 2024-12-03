## A node that displays dialogue for cutscenes.
class_name Dialogue
extends ReferenceRect

## Possible positions for a portrait.
enum Positions {
	OUTSIDE_LEFT = -80,
	FAR_LEFT = 0,
	MID_LEFT = 80,
	CLOSE_LEFT = 160,
	CLOSE_RIGHT = 256,
	MID_RIGHT = 336,
	FAR_RIGHT = 416,
	OUTSIDE_RIGHT = 512
}

const _FULL_SCROLL_SPEED: float = 0.25
const _LINE_COUNT: int = 5
const _SHIFT_DURATION: float = 8.0 / 60  # In seconds
const _TEXT_BOX_HEIGHT: int = 94
const _PORTRAIT_WIDTH: int = 96

var _portraits: Dictionary = {}
var _top_speaker: Unit
var _bottom_speaker: Unit
var _skipping: bool = false
@onready var _top_bubble_point := $TopBubblePoint as TextureRect
@onready var _bottom_bubble_point := $BottomBubblePoint as TextureRect
@onready var _top_text_box := %TopTextBox as RichTextLabel
@onready var _bottom_text_box := %BottomTextBox as RichTextLabel


func _receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var portraits: Array[Unit] = []
		portraits.assign(_portraits.keys())
		var last_portrait: Unit = portraits.pop_back()
		for portrait: Unit in portraits:
			remove_portrait(portrait)
		await remove_portrait(last_portrait)
		hide_top_text_box()
		await hide_bottom_text_box()
		_skipping = true


## Sets the text to be displayed in the top text box.
func set_top_text(string: String) -> void:
	if not _skipping:
		await _set_text_base(
			string, _top_text_box, _portraits.get(_top_speaker, Portrait.new()) as Portrait
		)


## Sets the text to be displayed in the bottom text box.
func set_bottom_text(string: String) -> void:
	if not _skipping:
		await _set_text_base(
			string, _bottom_text_box, _portraits.get(_bottom_speaker, Portrait.new()) as Portrait
		)


## Removes the text in the top text box.
func clear_top() -> void:
	await _clear(_top_text_box)


## Removes the text in the bottom text box.
func clear_bottom() -> void:
	await _clear(_bottom_text_box)


## Sets the speaker for the top text box.
func set_top_speaker(new_speaker: Unit) -> void:
	if not _skipping:
		_top_speaker = new_speaker
		if new_speaker in _portraits.keys():
			_configure_point(
				_top_bubble_point, roundi(_get_portrait(new_speaker as Unit).position.x)
			)
		await clear_top()
		await _set_speaker(%TopName as RichTextLabel, new_speaker as Unit)


## Sets the speaker for the bottom text box.
func set_bottom_speaker(new_speaker: Unit) -> void:
	if not _skipping:
		_bottom_speaker = new_speaker
		if new_speaker in _portraits.keys():
			_configure_point(
				_bottom_bubble_point, roundi(_get_portrait(new_speaker as Unit).position.x)
			)
		await clear_bottom()
		await _set_speaker(%BottomName as RichTextLabel, new_speaker as Unit)


## Adds a portrait to the current scene.
func add_portrait(new_speaker: Unit, portrait_position: Positions, flip_h: bool = false) -> void:
	if not _skipping:
		var portrait: Portrait = new_speaker.get_portrait()
		if flip_h:
			portrait.flip()
		portrait.position = Vector2i(portrait_position, 20)
		$Portraits.add_child(portrait)
		_portraits[new_speaker] = portrait
		var tween: Tween = create_tween()
		portrait.modulate.v = 0
		tween.tween_property(portrait, "modulate:v", 1, _SHIFT_DURATION)
		await tween.finished


## Removes a portrait from the scene.
func remove_portrait(old_speaker: Unit) -> void:
	if not _skipping:
		var portrait := Portrait.new()
		if is_instance_valid(_portraits.get(old_speaker)):
			portrait = _portraits.get(old_speaker, Portrait.new())
		var tween: Tween = create_tween()
		tween.tween_property(portrait, "modulate:v", 0, _SHIFT_DURATION)
		await tween.finished
		portrait.queue_free()


## Displays the top text box.
func show_top_text_box(box_position: Positions) -> void:
	await _show_text_box(
		box_position, $MarginContainerTop as MarginContainer, false, _top_bubble_point
	)


## Displays the bottom text box.
func show_bottom_text_box(box_position: Positions) -> void:
	await _show_text_box(
		box_position, $MarginContainerBottom as MarginContainer, true, _bottom_bubble_point
	)


## Removes the top text box.
func hide_top_text_box() -> void:
	await _hide_text_box($MarginContainerTop as MarginContainer, false, _top_bubble_point)


## Removes the bottom text box.
func hide_bottom_text_box() -> void:
	await _hide_text_box($MarginContainerBottom as MarginContainer, true, _bottom_bubble_point)


func _show_text_box(
	box_position: Positions,
	text_box: MarginContainer,
	align_bottom: bool,
	bubble_point: TextureRect
) -> void:
	if not _skipping:
		text_box.visible = true
		_configure_point(bubble_point, box_position)
		await _resize_text_box(
			text_box,
			align_bottom,
			bubble_point,
			text_box.custom_minimum_size,
			Vector2i(Utilities.get_screen_size().x, _TEXT_BOX_HEIGHT)
		)
		text_box.position.x = 0
		if align_bottom:
			text_box.position.y = (Utilities.get_screen_size().y - text_box.size.y)
			bubble_point.position.y = text_box.position.y - bubble_point.size.y + 2
		else:
			bubble_point.position.y = text_box.size.y - 2


func _hide_text_box(
	text_box: MarginContainer, align_bottom: bool, bubble_point: TextureRect
) -> void:
	if not _skipping:
		await _resize_text_box(
			text_box,
			align_bottom,
			bubble_point,
			Vector2i(Utilities.get_screen_size().x, _TEXT_BOX_HEIGHT),
			text_box.custom_minimum_size
		)
		text_box.visible = false
		bubble_point.visible = false


func _resize_text_box(
	text_box: MarginContainer,
	align_bottom: bool,
	bubble_point: TextureRect,
	starting_size: Vector2,
	target_size: Vector2
) -> void:
	var target_x: float = bubble_point.position.x + bubble_point.size.x / 2
	text_box.anchor_left = target_x / Utilities.get_screen_size().x
	text_box.anchor_right = text_box.anchor_left

	var adjust_size: Callable = func(new_size: Vector2) -> void:
		text_box.size = new_size.snapped(Vector2i(2, 2))
		text_box.position.x = clampf(
			target_x - text_box.size.x / 2, 0, Utilities.get_screen_size().x - text_box.size.x
		)
		if align_bottom:
			text_box.position.y = (Utilities.get_screen_size().y - text_box.size.y)
			bubble_point.position.y = text_box.position.y - bubble_point.size.y + 2
		else:
			bubble_point.position.y = text_box.size.y - 2

	var tween: Tween = create_tween()
	tween.tween_method(adjust_size, starting_size, target_size, _SHIFT_DURATION)
	await tween.finished


func _set_text_base(string: String, label: RichTextLabel, portrait: Portrait) -> void:
	if not _skipping:
		portrait.set_talking(true)
		label.text += string
		label.visible_ratio = 0
		if string.length() == 0:
			label.visible_ratio = 1
		label.visible_characters = label.text.length() - string.length()
		var auto_scroll: bool = false
		#region Gradually displays text
		while label.visible_ratio < 1 and not _skipping:
			if not auto_scroll:
				await get_tree().physics_frame
			if Input.is_action_just_pressed("ui_accept"):
				auto_scroll = true
				await get_tree().physics_frame  # Prevents input from being double read
			var next_visible_chars: int = (
				label.visible_characters + roundi(_get_text_speed() * get_process_delta_time())
			)
			while label.visible_characters < next_visible_chars and label.visible_ratio < 1:
				label.visible_characters += 1
				# Scrolls when overflowing
				if label.get_line_count() > _LINE_COUNT + (label.position.y / -_get_line_height()):
					label.visible_characters -= 1
					auto_scroll = false
					await _scroll(label)
					break
				# Delays for punctuation
				elif label.text[label.visible_characters - 1] in [",", ".", ";", ":"]:
					if not auto_scroll:
						await get_tree().create_timer(15.0 / _get_text_speed()).timeout
					break
		label.visible_ratio = 1
		#endregion
		if portrait:
			portrait.set_talking(false)
		while not (Input.is_action_just_pressed("ui_accept") or _skipping):
			await get_tree().physics_frame


func _scroll(label: RichTextLabel) -> void:
	if not _skipping:
		var new_y: int = roundi(label.position.y - _get_line_height())
		var tween: Tween = create_tween()
		tween.tween_property(label, "position:y", new_y, _FULL_SCROLL_SPEED / _LINE_COUNT)
		await tween.finished


func _clear(label: RichTextLabel) -> void:
	for i: int in _LINE_COUNT:
		await _scroll(label)
	label.text = ""
	label.position.y = 0


func _get_line_height() -> int:
	return 16 + _top_text_box.get_theme_constant("line_separation")


func _set_speaker(name_label: RichTextLabel, new_speaker: Unit) -> void:
	if not _skipping:
		if name_label.text != "":
			var slide_out: Tween = create_tween()
			slide_out.set_speed_scale(2)
			slide_out.tween_property(name_label, "visible_ratio", 0, _SHIFT_DURATION)
			await slide_out.finished
		name_label.text = new_speaker.display_name
		var slide_in: Tween = create_tween()
		slide_in.set_speed_scale(2)
		slide_in.tween_property(name_label, "visible_ratio", 1, _SHIFT_DURATION / 2)
		await slide_in.finished


func _configure_point(bubble_point: TextureRect, point_x: int) -> void:
	bubble_point.visible = true
	bubble_point.flip_h = point_x < (float(Utilities.get_screen_size().y) / 2)
	bubble_point.position.x = (
		float(point_x + _PORTRAIT_WIDTH) if bubble_point.flip_h else point_x - bubble_point.size.x
	)


func _get_portrait(unit: Unit) -> Portrait:
	return _portraits[unit]


func _get_text_speed() -> int:
	const BASE_SPEED: int = 150
	match Options.TEXT_SPEED.value:
		Options.TEXT_SPEED.SLOW:
			return roundi(BASE_SPEED * 0.5)
		Options.TEXT_SPEED.MEDIUM:
			return BASE_SPEED
		Options.TEXT_SPEED.FAST:
			return BASE_SPEED * 2
		Options.TEXT_SPEED.MAX:
			return 4294967296 # Can't be infinite or causes issues;
		_:
			push_warning(Options.TEXT_SPEED.get_error_message())
			return BASE_SPEED
