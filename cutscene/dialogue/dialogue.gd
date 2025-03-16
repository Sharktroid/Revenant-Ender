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

var _portraits: Dictionary[StringName, Portrait] = {}
var _top_speaker: String
var _bottom_speaker: String
var _skipping: bool = false
@onready var _top_bubble_point := $TopBubblePoint as TextureRect
@onready var _bottom_bubble_point := $BottomBubblePoint as TextureRect
@onready var _top_text_box := %TopTextBox as RichTextLabel
@onready var _bottom_text_box := %BottomTextBox as RichTextLabel


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		_skipping = true


## Runs a script file. Path to the script file is relative to the map's root.
func parse_script(script_name: StringName, map: Map) -> void:
	_skipping = false
	var map_path: String = (map.get_script() as GDScript).resource_path

	var file_path: String = map_path.replace(map_path.get_file(), "%s.eodscript" % script_name)
	var file := FileAccess.open(file_path, FileAccess.READ)
	var lines: Array[String] = []
	while file.get_position() < file.get_length():
		lines.append(file.get_line())
	lines = _parse_quotations(lines, "\n")
	for line in lines:
		if _skipping:
			break
		var commands: Array[String] = _parse_quotations(line.split(", "), ", ")
		var command_counter := Counter.new(commands.size())
		for command in commands:
			command_counter.call_and_increment(_run_command.bind(command))
		if not command_counter.is_limit_reached():
			await command_counter.limit_reached
	var portraits: Array[StringName] = []
	portraits.assign(_portraits.keys())
	var portrait_counter := Counter.new(portraits.size())
	for portrait: StringName in portraits:
		portrait_counter.call_and_increment(_remove_portrait.bind(portrait))
	if portrait_counter.is_limit_reached():
		await portrait_counter.limit_reached
	var close_counter := Counter.new(2)
	close_counter.call_and_increment(_hide_text_box.bind(true))
	close_counter.call_and_increment(_hide_text_box.bind(false))
	if close_counter.is_limit_reached():
		await close_counter.limit_reached


func _run_command(command: String) -> void:
	var arguments: Array[String] = _parse_quotations(command.split(" "), " ")
	match arguments.pop_front():
		"SHOW":
			await _show_text_box(arguments[0] == "TOP")
		"HIDE":
			await _hide_text_box(arguments[0] == "TOP")
		"ADD_PORTRAIT":
			await _add_portrait(
				arguments[0], Positions[arguments[1]] as Positions, arguments[2] == "RIGHT"
			)
		"REMOVE_PORTRAIT":
			await _remove_portrait(arguments[0])
		"TALK":
			await _set_text(
				arguments[0] == "TOP", arguments[1], Utilities.slice_string(arguments[2], 1, 1)
			)
		"CLEAR":
			await _clear(arguments[0] == "TOP")
		var invalid_command:
			push_error("Invalid command: %s" % invalid_command)


func _parse_quotations(lines: Array[String], joiner: String = "") -> Array[String]:
	var output: Array[String] = []
	var current_line: String
	while lines.size() > 0:
		current_line = lines.pop_front()
		while (current_line.count('"') - current_line.count('\\"')) % 2 == 1:
			current_line += joiner + lines.pop_front()
		output.append(current_line)
	return output


## Adds a portrait to the current scene.
func _add_portrait(
	new_speaker: StringName, portrait_position: Positions, flip_h: bool = false
) -> void:
	var path: String = "res://portraits/{speaker}/{speaker}.tscn".format(
		{speaker = new_speaker.to_lower()}
	)
	var packed_portrait := load(path) as PackedScene
	var portrait := packed_portrait.instantiate() as Portrait
	if flip_h:
		portrait.flip()
	portrait.position = Vector2i(portrait_position, 20)
	$Portraits.add_child(portrait)
	_portraits[new_speaker] = portrait
	var tween: Tween = create_tween()
	portrait.modulate.v = 0
	tween.tween_property(portrait, ^"modulate:v", 1, _SHIFT_DURATION)
	await tween.finished


## Removes a portrait from the scene.
func _remove_portrait(old_speaker: StringName) -> void:
	var portrait := Portrait.new()
	if is_instance_valid(_portraits.get(old_speaker)):
		portrait = _portraits[old_speaker]
	var tween: Tween = create_tween()
	tween.tween_property(portrait, ^"modulate:v", 0, _SHIFT_DURATION)
	await tween.finished
	portrait.queue_free()


func _get_bubble_point(top: bool) -> TextureRect:
	return _top_bubble_point if top else _bottom_bubble_point


func _get_margin_container(top: bool) -> MarginContainer:
	return $MarginContainerTop if top else $MarginContainerBottom


func _show_text_box(top: bool) -> void:
	var text_box: MarginContainer = _get_margin_container(top)
	text_box.visible = true
	var bubble_point: TextureRect = _get_bubble_point(top)
	await _resize_text_box(
		text_box,
		not top,
		bubble_point,
		text_box.custom_minimum_size,
		Vector2i(Utilities.get_screen_size().x, _TEXT_BOX_HEIGHT)
	)
	text_box.position.x = 0
	if top:
		bubble_point.position.y = text_box.size.y - 2
	else:
		text_box.position.y = (Utilities.get_screen_size().y - text_box.size.y)
		bubble_point.position.y = text_box.position.y - bubble_point.size.y + 2


func _hide_text_box(top: bool) -> void:
	_get_text_box(top).text = ""
	var text_box: MarginContainer = _get_margin_container(top)
	var bubble_point := _top_bubble_point if top else _bottom_bubble_point
	await _resize_text_box(
		text_box,
		not top,
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


func _get_text_box(top: bool) -> RichTextLabel:
	return _top_text_box if top else _bottom_text_box


func _set_text(top: bool, unit_name: String, string: String) -> void:
	if not _get_margin_container(top).visible:
		await _show_text_box(top)
	await _update_speaker(top, unit_name)
	var portrait: Portrait = _portraits[unit_name]
	portrait.set_talking(true)
	var label: RichTextLabel = _get_text_box(top)
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
		if Input.is_action_just_pressed("select"):
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
	while not (Input.is_action_just_pressed("select") or _skipping):
		await get_tree().physics_frame


func _scroll(label: RichTextLabel) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(
		label,
		^"position:y",
		roundi(label.position.y - _get_line_height()),
		_FULL_SCROLL_SPEED / _LINE_COUNT
	)
	await tween.finished


func _clear(top: bool) -> void:
	var label: RichTextLabel = _top_text_box if top else _bottom_text_box
	for i: int in _LINE_COUNT:
		await _scroll(label)
	label.text = ""
	label.position.y = 0


func _get_line_height() -> int:
	return 16 + _top_text_box.get_theme_constant("line_separation")


func _update_speaker(top: bool, new_speaker: StringName) -> void:
	var current_speaker: String = _top_speaker if top else _bottom_speaker
	if new_speaker == current_speaker:
		return
	var portrait: Portrait = _portraits[new_speaker]
	if new_speaker in _portraits.keys():
		_configure_point(_get_bubble_point(top), roundi(portrait.position.x))
	var counter := Counter.new(1)
	var async_speaker: Callable = func() -> void:
		await _set_speaker(top, new_speaker)
		counter.increment()
	async_speaker.call()
	await _clear(top)
	if not counter.is_limit_reached():
		await counter.limit_reached


func _set_speaker(top: bool, new_speaker: StringName) -> void:
	if top:
		_top_speaker = new_speaker
	else:
		_bottom_speaker = new_speaker
	var name_label := (%TopName if top else %BottomName) as RichTextLabel
	if name_label.text != "":
		var slide_out: Tween = create_tween()
		slide_out.set_speed_scale(2)
		slide_out.tween_property(name_label, ^"visible_ratio", 0, _SHIFT_DURATION)
		await slide_out.finished
	name_label.text = new_speaker
	var slide_in: Tween = create_tween()
	slide_in.set_speed_scale(2)
	slide_in.tween_property(name_label, ^"visible_ratio", 1, _SHIFT_DURATION / 2)
	await slide_in.finished


func _configure_point(bubble_point: TextureRect, point_x: int) -> void:
	bubble_point.visible = true
	bubble_point.flip_h = point_x < (float(Utilities.get_screen_size().y) / 2)
	bubble_point.position.x = (
		float(point_x + _PORTRAIT_WIDTH) if bubble_point.flip_h else point_x - bubble_point.size.x
	)


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
			return 4294967296  # Can't be infinite or causes issues
		_:
			push_warning(Options.TEXT_SPEED.get_error_message())
			return BASE_SPEED
