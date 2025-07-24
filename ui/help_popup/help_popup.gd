extends PanelContainer


func display_contents(display: bool) -> void:
	(%HelpGrid as GridContainer).visible = display
	reset_size()


func get_default_size() -> Vector2:
	display_contents(false)
	var default_size: Vector2 = size
	display_contents(true)
	return default_size


func clear_nodes() -> void:
	for child: Node in %HelpGrid.get_children():
		child.queue_free()
		await child.tree_exited
	reset_size()


## Adds every node from each page to the popup node.
func add_nodes(nodes: Array[Array]) -> void:
	for page: Array[Control] in nodes:
		for node: Control in page:
			%HelpGrid.add_child(node)
			node.visible = false

## Makes the nodes visible and others hidden.
func set_nodes(nodes: Array[Control]) -> void:
	for child: Control in %HelpGrid.get_children():
		child.visible = false
	for node: Control in nodes:
		node.visible = true
	reset_size()


func get_nodes_size(nodes: Array[Control]) -> Vector2:
	var current_nodes: Array[Control] = []
	current_nodes.assign(%HelpGrid.get_children().filter(
		func(node: Control) -> bool:
			return node.visible
	))
	set_nodes(nodes)
	var total_size: Vector2 = size
	set_nodes(current_nodes)
	return total_size
