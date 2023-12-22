extends Control

const CHARS_PER_SECOND: int = 300
const FULL_SCROLL_SPEED: float = 0.25
const LINE_COUNT: int = 5
const SHIFT_DURATION: int = 8 # In ticks

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

func _ready() -> void:
	await get_tree().physics_frame
	add_portrait(units.roy, positions.CLOSERIGHT)
	add_portrait(units.lance, positions.MIDLEFT, true)
	set_top_speaker(units.roy)
	await set_bottom_speaker(units.lance)
	await set_top_text("Oh, it's Lance! What's the matter? Why are you in such a hurry?")
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
	await set_top_text("Yes, you're right. This is no time to despair. Very well. \
To arms then! Our target is the castle! We must rescue everyone!")


func set_top_text(string: String) -> void:
	await _set_text_base(string, %"Top Textbox" as RichTextLabel)


func set_bottom_text(string: String) -> void:
	await _set_text_base(string, %"Bottom Textbox" as RichTextLabel)


func clear_top() -> void:
	await _clear(%"Top Textbox" as RichTextLabel)


func clear_bottom() -> void:
	await _clear(%"Bottom Textbox" as RichTextLabel)


func set_top_speaker(new_speaker: Variant) -> void:
	_top_speaker = new_speaker
	if new_speaker in _portraits.keys():
		_configure_point(_top_bubble_point, _portraits[new_speaker] as TextureRect)
	await clear_top()
	await _set_speaker(%"Top Name" as RichTextLabel, new_speaker as Unit)



func set_bottom_speaker(new_speaker: Variant) -> void:
	_bottom_speaker = new_speaker
	if new_speaker in _portraits.keys():
		_configure_point(_bottom_bubble_point, _portraits[new_speaker] as TextureRect)
	await clear_bottom()
	await _set_speaker(%"Bottom Name" as RichTextLabel, new_speaker as Unit)


func add_portrait(new_speaker: Variant, portrait_position: positions,
		flip_h: bool = false) -> void:
	var portrait := TextureRect.new()
	portrait.flip_h = flip_h
	portrait.texture = (new_speaker as Unit).get_portrait()
	portrait.position = Vector2i(portrait_position, 20)
	portrait.modulate.v = 0
	$VBoxContainer/Portraits.add_child(portrait)
	_portraits[new_speaker] = portrait
	for i in SHIFT_DURATION:
		portrait.modulate.v = remap(i, 0, SHIFT_DURATION, 0, 1)
		await get_tree().physics_frame
	portrait.modulate.v = 1


func remove_portrait(new_speaker: Variant) -> void:
	var portrait: TextureRect = _portraits.get(new_speaker, TextureRect.new())
	portrait.modulate.v = 1
	for i in SHIFT_DURATION:
		portrait.modulate.v = remap(i, 0, SHIFT_DURATION, 1, 0)
		await get_tree().physics_frame
	portrait.queue_free()


func _set_text_base(string: String, label: RichTextLabel) -> void:
	label.text += string
	label.visible_ratio = 0
	if string.length() == 0:
		label.visible_ratio = 1
	label.visible_characters = label.text.length() - string.length()
	#region Gradually displays text
	while label.visible_ratio < 1:
		await get_tree().process_frame
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
	while not Input.is_action_just_pressed("ui_accept"):
		await get_tree().process_frame


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


func _configure_point(_bubble_point: TextureRect, portrait: TextureRect) -> void:
	_bubble_point.visible = true
	if (portrait.position.x <
			ProjectSettings.get_setting("display/window/size/viewport_width")/2):
		_bubble_point.flip_h = true
		_bubble_point.position.x = portrait.position.x + portrait.size.x
	else:
		_bubble_point.flip_h = false
		_bubble_point.position.x = portrait.position.x - _bubble_point.size.x
