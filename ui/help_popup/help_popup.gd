extends PanelContainer


func display_contents(display: bool) -> void:
	(%HelpGrid as GridContainer).visible = display


func clear_nodes() -> void:
	for child: Node in %HelpGrid.get_children():
		child.queue_free()
		await child.tree_exited


func add_table(table: Table) -> void:
	if table:
		var table_node: GridContainer = table.to_grid_container()
		table_node.name = "Table"
		%HelpGrid.add_child(table_node)
		reset_size()


func add_description(description_text: String) -> void:
	if description_text.length() != 0:
		var description := RichTextLabel.new()
		description.autowrap_mode = TextServer.AUTOWRAP_OFF
		description.text = description_text
		description.size_flags_vertical = Control.SIZE_EXPAND_FILL
		description.fit_content = true
		description.scroll_active = false
		if size.x > Utilities.get_screen_size().x:
			description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			size.x = Utilities.get_screen_size().x
		%HelpGrid.add_child(description)
		reset_size()
