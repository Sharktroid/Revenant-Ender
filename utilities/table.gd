class_name Table
extends RefCounted

## The exclusive bounds of the table.
var size: Vector2i:
	set(value):
		if value.sign() != Vector2i.ONE:
			if value.abs() != value:
				push_error("Can not assign a negative size.")
			value = Vector2.ZERO
		if size.x > value.x or size.y > value.y:
			for cell: Vector2i in _cells.keys():
				if (size - cell).sign() != Vector2i.ONE:
					_cells.erase(cell)
		size = value
var _cells: Dictionary[Vector2i, Cell] = {}


## Turns a dictionary into a BBCode table.
static func from_dictionary(dict: Dictionary[String, String], width: int) -> Table:
	var table := Table.new()
	table.size = Vector2i(width * 2, floori(float(dict.size()) / width))
	for index: int in dict.size():
		var x_offset: int = (index % width) * 2
		var y_offset: int = floori(float(index) / width)
		table.set_cell(Vector2i(x_offset, y_offset), Cell.new(dict.keys()[index] as String, true))
		table.set_cell(Vector2i(x_offset + 1, y_offset), Cell.new(dict.values()[index] as String))
	return table


func set_cell(position: Vector2i, cell: Cell, expand: bool = false) -> void:
	if expand:
		size = size.max(position)
	elif position.min(size) != position:
		push_error(
			"New position {position} out of bounds of Table of size {size}.".format(
				{"position": position, "size": size}
			)
		)
	_cells[position] = cell


func get_cell(position: Vector2i) -> Cell:
	return _cells.get_or_add(position, Cell.new())


func to_grid_container() -> GridContainer:
	var grid_container := GridContainer.new()
	grid_container.columns = size.x
	for y in size.y:
		for x in size.x:
			var item: Label = Label.new()
			item.name = _get_node_name(x, y)
			var cell: Cell = get_cell(Vector2i(x, y))
			item.text = cell.text
			_set_header(item, cell.header)
			grid_container.add_child(item)
	return grid_container


func _set_header(item: Label, is_header: bool) -> void:
	if is_header:
		item.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		item.add_theme_color_override("font_color", Utilities.FONT_YELLOW)
	else:
		item.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		item.add_theme_color_override("font_color", Utilities.FONT_BLUE)


static func _get_node_name(x: int, y: int) -> String:
	return "{x}, {y}".format({"x": x, "y": y})


class Cell:
	extends RefCounted
	## The text displayed by the cell.
	var text: String
	## Whether the cell is a header cell.
	var header: bool = false

	func _init(_text: String = "", _header: bool = false) -> void:
		text = _text
		header = _header
