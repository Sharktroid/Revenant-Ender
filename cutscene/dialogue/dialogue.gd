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

static var units: Dictionary = {
	roy = ((preload("uid://cuqamu0m16iep").instantiate()) as Unit),
	lance = preload("uid://blysgn0u4e6ar").instantiate() as Unit,
	alen = preload("uid://8gwj2xxrhmht").instantiate() as Unit,
	bors = preload("uid://b4oirte2lakpd").instantiate() as Unit,
	wolt = preload("uid://8f0f7er5vqbo").instantiate() as Unit,
	marcus = preload("uid://dvkbmwwrt5mmo").instantiate() as Unit,
}

@onready var _top_bubble_point: TextureRect = $"Top Bubble Point"
@onready var _bottom_bubble_point: TextureRect = $"Bottom Bubble Point"
var _portraits: Dictionary = {}
var _top_speaker: Unit
var _bottom_speaker: Unit

func _ready() -> void:
	for node: Unit in units.values():
		add_child(node)
		node.visible = false

#region Test Dialogue
	while not Input.is_action_just_pressed("ui_accept"):
		await get_tree().physics_frame
	await show_top_textbox(positions.CLOSERIGHT)
	add_portrait(units.roy, positions.CLOSERIGHT)
	add_portrait(units.lance, positions.MIDLEFT, true)
	await set_top_speaker(units.roy)
	await set_top_text("Oh, it's Lance! What's the matter? Why are you in such a hurry?")
	await show_bottom_textbox(positions.MIDLEFT)
	await set_bottom_speaker(units.lance)
	await set_bottom_text("Lord Roy! Bandits have appeared and are attacking the
castle as we speak!")
	add_portrait(units.alen, positions.FARRIGHT)
	await set_top_speaker(units.alen)
	await set_top_text("No! Is the marquess unharmed?")
	await clear_bottom()
	await set_bottom_text("He's inside, defending against the bandits' attack. \
But I don't know how long he can last with his illness...!")
	await remove_portrait(units.alen)
	add_portrait(units.bors, positions.FARRIGHT)
	await set_top_speaker(units.bors)
	await set_top_text("Excuse me. Lance, is it? Is Lady Lilina safe?")
	await clear_bottom()
	await set_bottom_text("You must be a knight of Ostia. \
Lady Lilina is in the castle. She should be all right. \
She's with Lord Eliwood after all, but he can't last forever.")
	remove_portrait(units.bors)
	await set_top_speaker(units.roy)
	await set_top_text("No... I shouldn't have let Lilina go to the castle before me.")
	await remove_portrait(units.lance)
	add_portrait(units.wolt, positions.FARLEFT, true)
	await set_bottom_speaker(units.wolt)
	await set_bottom_text("Lord Roy, regret won't solve anything! \
We must retake the castle!")
	add_portrait(units.marcus, positions.CLOSELEFT, true)
	await set_bottom_speaker(units.marcus)
	await set_bottom_text("Wolt is right. We must make haste!")
	await clear_top()
	remove_portrait(units.wolt)
	await remove_portrait(units.marcus)
	await hide_bottom_textbox()
	await set_top_text("Yes, you're right. This is no time to despair. Very well. \
To arms then! Our target is the castle! We must rescue everyone!")
	await remove_portrait(units.roy)
	await hide_top_textbox()
#endregion


func set_top_text(string: String) -> void:
	await _set_text_base(string, %"Top Textbox" as RichTextLabel,
			_top_speaker.get_portrait())


func set_bottom_text(string: String) -> void:
	await _set_text_base(string, %"Bottom Textbox" as RichTextLabel,
			_bottom_speaker.get_portrait())


func clear_top() -> void:
	await _clear(%"Top Textbox" as RichTextLabel)


func clear_bottom() -> void:
	await _clear(%"Bottom Textbox" as RichTextLabel)


func set_top_speaker(new_speaker: Variant) -> void:
	_top_speaker = new_speaker
	if new_speaker in _portraits.keys():
		_configure_point(_top_bubble_point,
				roundi(_get_portrait(new_speaker as Unit).position.x))
	await clear_top()
	await _set_speaker(%"Top Name" as RichTextLabel, new_speaker as Unit)


func set_bottom_speaker(new_speaker: Variant) -> void:
	_bottom_speaker = new_speaker
	if new_speaker in _portraits.keys():
		_configure_point(_bottom_bubble_point,
				roundi(_get_portrait(new_speaker as Unit).position.x))
	await clear_bottom()
	await _set_speaker(%"Bottom Name" as RichTextLabel, new_speaker as Unit)


func add_portrait(new_speaker: Variant, portrait_position: positions,
		flip_h: bool = false) -> void:
	var portrait: Portrait = (new_speaker as Unit).get_portrait()
	portrait.request_ready()
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


func remove_portrait(new_speaker: Variant) -> void:
	var portrait: Portrait = _portraits.get(new_speaker, Portrait.new())
	portrait.modulate.v = 1
	for i in SHIFT_DURATION:
		portrait.modulate.v = remap(i, 0, SHIFT_DURATION, 1, 0)
		await get_tree().physics_frame
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
	portrait.set_talking(true)
	label.text += string
	label.visible_ratio = 0
	if string.length() == 0:
		label.visible_ratio = 1
	label.visible_characters = label.text.length() - string.length()
	#region Gradually displays text
	while label.visible_ratio < 1:
		await get_tree().physics_frame
		var next_visible_chars: int = (label.visible_characters +
				roundi(CHARS_PER_SECOND * GenVars.get_frame_delta()))
		while (label.visible_characters < next_visible_chars and label.visible_ratio < 1):
			label.visible_characters += 1
			# Scrolls when overflowing
			if label.get_line_count() > LINE_COUNT + (label.position.y/-_get_line_height()):
				label.visible_characters -= 1
				await _scroll(label)
				break
			# Delays for punctuation
			elif label.text[label.visible_characters - 1] in [",", ".", ";", ":"]:
				await get_tree().create_timer(0.1).timeout
				break
	label.text += ""
	label.visible_ratio = 1
	#endregion
	portrait.set_talking(false)
	while not Input.is_action_just_pressed("ui_accept"):
		await get_tree().physics_frame


func _scroll(label: RichTextLabel) -> void:
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
