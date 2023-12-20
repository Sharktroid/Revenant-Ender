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
		set_top_name("Roy"): true,
		set_top_text("Oh, it's Lance! What's the matter? Why are you in such a hurry?."): true,
		set_bottom_name("Lance"): true,
		set_bottom_text("Lord Roy! Bandits have appeared and are attacking the \
castle as we speak!"): true,
		set_top_name("Alen"): true,
		set_top_text("No! Is the marquess unharmed?"): true,
		clear_bottom(): true,
	 	set_bottom_text("He's inside, defending against the bandits' attack. \
But I don't know how long he can last with his illness...!"): true,
		set_top_name("Bors"): true,
		set_top_text("Excuse me. Lance, is it? Is Lady Lilina safe?"): true,
		clear_bottom(): true,
	 	set_bottom_text("You must be a knight of Ostia. \
Lady Lilina is in the castle. She should be all right. \
She's with Lord Eliwood after all, but he can't last forever."): true,
		set_top_name("Roy"): true,
		set_top_text("No... I shouldn't have let Lilina go to the castle before me."): true,
		set_bottom_name("Wolt"): true,
	 	set_bottom_text("Lord Roy, regret won't solve anything! \
We must retake the castle!"): true,
		set_bottom_name("Marcus"): true,
	 	set_bottom_text("Wolt is right. We must make haste!"): true,
		clear_top(): true,
		set_top_text("Yes, you're right. This is no time to despair. Very well. \
To arms then! Our target is the castle! We must rescue everyone!"): true,
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


func clear_bottom() -> Callable:
	return _clear(%"Bottom Textbox" as RichTextLabel)


func set_top_name(new_name: String) -> Callable:
	return func() -> void:
		await clear_top().call()
		await _set_name(%"Top Name" as RichTextLabel, new_name).call()


func set_bottom_name(new_name: String) -> Callable:
	return func() -> void:
		await clear_bottom().call()
		await _set_name(%"Bottom Name" as RichTextLabel, new_name).call()


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
