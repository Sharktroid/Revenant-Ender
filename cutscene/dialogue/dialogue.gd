extends Control

const CHARS_PER_SECOND = 300

enum positions {OUTSIDELEFT = -80, FARLEFT = 0, MIDLEFT = 80, CLOSELEFT = 160,
		CLOSERIGHT = 256, MIDRIGHT = 336, FARRIGHT = 416, OUTSIDERIGHT = 512}
enum directions {LEFT, RIGHT}

func _ready() -> void:
	var top_text: String = "After defeating the dragons, the humans of Elibe quickly spread their culture and civilization to the farthest reaches of the continent.\nIn the west lies the Kingdom of Etruria, which is widely considered to possess the most refined culture in all of Elibe. The Kingdom of Bern, with its powerful military and logical, pragmatic people, is located on the other side of the continent in the east."
	var bottom_text: String = "These are the two most powerful nations in Elibe with the weaker nations situated between them. These smaller lands are... the Lycian League, whose numerous territories are independently ruled by a number of marquesses that are bound by a vow of allegiance; Ilia, where the people arduously till the frozen soil and many become mercenaries to earn money to survive; and Sacae, where various clans ride through the plains on horseback."
	await get_tree().process_frame
	var dialogue_queue: Array[Callable] = [set_top_text(top_text), set_bottom_text(bottom_text)]
	for callable: Callable in dialogue_queue:
		await callable.call()


func set_top_text(string: String) -> Callable:
	return _set_text_base(string, %"Top Textbox" as RichTextLabel)


func set_bottom_text(string: String) -> Callable:
	return _set_text_base(string, %"Bottom Textbox" as RichTextLabel)


func _set_text_base(string: String, label: RichTextLabel) -> Callable:
	return func():
		label.text = string
		if label.get_line_count() > 5:
			push_error("Too much text added to %s. Contents will be cut off." % label.get_path())
		label.visible_characters = 0
		#region Gradually displays text
		while label.visible_ratio < 1:
			await get_tree().process_frame
			var next_visible_chars: int = (label.visible_characters +
					roundi(CHARS_PER_SECOND * GenVars.get_frame_delta()))
			while (label.visible_characters < next_visible_chars):
				label.visible_characters += 1
				if label.text[label.visible_characters - 1] in [",", ".", ";", ":"]: # Delays for punctuation
					await get_tree().create_timer(0.1).timeout
					break
		#endregion
		while not Input.is_action_just_pressed("ui_accept"):
			await get_tree().process_frame
