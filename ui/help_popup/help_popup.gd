extends PanelContainer


func display_contents(display: bool) -> void:
	($"PanelContainer3/MarginContainer/VBoxContainer" as VBoxContainer).visible = display


func set_table(table_items: Array[String], columns: int) -> void:
	var table: GridContainer = (%Table as GridContainer)
	if table_items.size() == 0:
		table.visible = false
	else:
		table.visible = true
		table.columns = columns
		for child: Node in table.get_children():
			child.queue_free()
			table.remove_child(child)
		for table_item: String in table_items:
			var label := RichTextLabel.new()
			label.bbcode_enabled = true
			label.fit_content = true
			label.autowrap_mode = TextServer.AUTOWRAP_OFF
			label.text = table_item
			table.add_child(label)
	reset_size()


func set_description(description_text: String) -> void:
	var description: RichTextLabel = (%Description as RichTextLabel)
	description.visible = description_text.length() != 0
	if description.visible:
		description.autowrap_mode = TextServer.AUTOWRAP_OFF
		description.text = description_text
		reset_size()
		if size.x > Utilities.get_screen_size().x:
			description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			size.x = Utilities.get_screen_size().x
	reset_size()
