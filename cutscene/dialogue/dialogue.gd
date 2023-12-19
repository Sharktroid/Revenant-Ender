extends Control

const CHARS_PER_SECOND: int = 300
const FULL_SCROLL_SPEED: float = 0.25
const LINE_COUNT: int = 5
const NAME_SHIFT_DURATION: float = 8.0/60

enum positions {OUTSIDELEFT = -80, FARLEFT = 0, MIDLEFT = 80, CLOSELEFT = 160,
		CLOSERIGHT = 256, MIDRIGHT = 336, FARRIGHT = 416, OUTSIDERIGHT = 512}
enum directions {LEFT, RIGHT}
func _ready() -> void:
	var dialogue_queue: Dictionary = {
		set_top_name("Narrator"): false,
		set_top_text("After defeating the dragons, the humans of Elibe quickly \
spread their culture and civilization to the farthest reaches of the continent."): true,
		set_top_text("\nIn the west lies the Kingdom of Etruria, which is widely \
considered to possess the most refined culture in all of Elibe."): true,
		set_top_text(" The Kingdom of Bern, with its powerful military and \
logical, pragmatic people, is located on the other side of the continent in the \
east."): true,
		clear_top(): true,
	 	set_top_text("These are the two most powerful nations in Elibe with \
the weaker nations situated between them. These smaller lands are..."): true,
		set_top_text(" the Lycian League, whose numerous territories are \
independently ruled by a number of marquesses that are bound by a vow of \
allegiance;"): true,
		set_top_text(" Ilia, where the people arduously till the frozen soil \
and many become mercenaries to earn money to survive;"): true,
		set_top_text(" and Sacae, where various clans ride through the plains \
on horseback."): true,
	}
	for callable: Callable in dialogue_queue.keys():
		if dialogue_queue[callable]:
			await callable.call()
		else:
			callable.call()


func set_top_text(string: String) -> Callable:
	return _set_text_base(string, %"Top Textbox" as RichTextLabel)


func set_bottom_text(string: String) -> Callable:
	return _set_text_base(string, %"Bottom Textbox" as RichTextLabel)


func clear_top() -> Callable:
	return _clear(%"Top Textbox" as RichTextLabel)


func set_top_name(new_name: String) -> Callable:
	return _set_name(%"Top Name" as RichTextLabel, new_name)


func set_bottom_name(new_name: String) -> Callable:
	return _set_name(%"Bottom Name" as RichTextLabel, new_name)


func _set_text_base(string: String, label: RichTextLabel) -> Callable:
	return func():
		label.text += string
		label.visible_ratio = 0
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


func _get_scroll_callable(label: RichTextLabel) -> Callable:
	return func() -> void:
		var new_y: int = roundi(label.position.y - _get_line_height())
		while roundi(label.position.y) > new_y:
			label.position.y -= (_get_line_height() * LINE_COUNT)/60.0 / FULL_SCROLL_SPEED
			await get_tree().physics_frame
		label.position.y = roundi(label.position.y)


func _scroll(label: RichTextLabel) -> void:
	await _get_scroll_callable(label).call()


func _clear(label: RichTextLabel) -> Callable:
	return func() -> void:
		for i in LINE_COUNT:
			await _scroll(label)
		label.text = ""
		label.position.y = 0


func _get_line_height() -> int:
	return 16 + %"Top Textbox".get_theme_constant("line_separation")


func _set_name(name_label: RichTextLabel, new_name: String) -> Callable:
	return func() -> void:
		const CHANGE_PER_FRAME: float = 1.0/60 / (NAME_SHIFT_DURATION / 2)
		while name_label.visible_ratio > 0:
			name_label.visible_ratio -= CHANGE_PER_FRAME
			await get_tree().physics_frame
		name_label.visible_ratio = 0
		name_label.text = new_name
		while name_label.visible_ratio < 1:
			name_label.visible_ratio += CHANGE_PER_FRAME
			await get_tree().physics_frame
		name_label.visible_ratio = 1
