class_name MapMenuItem
extends HelpContainer

var value: String:
	set(new_value):
		value = new_value
		_update()
var selected: bool = false:
	set(value):
		selected = value
		if selected:
			_select()
		else:
			_deselect()

var _label := Label.new()


func _init() -> void:
	_deselect()
	selectable = false
	add_child(_label)
	mouse_entered.connect(_on_mouse_entered)


func _enter_tree() -> void:
	_update()
	if self == _get_parent_menu().get_current_item_node():
		selected = true


func _select() -> void:
	if _label.has_theme_color_override("font_color"):
		_label.remove_theme_color_override("font_color")


func _deselect() -> void:
	if not _label.has_theme_color_override("font_color"):
		_label.add_theme_color_override("font_color", Color.GRAY)


func _get_parent_menu() -> MapMenu:
	return get_parent().get_parent()


func _on_mouse_entered() -> void:
	super()
	if GameController.get_current_input_node() == _get_parent_menu():
		_get_parent_menu().set_current_item_node(self)


func _update() -> void:
	_label.text = (_get_name())


func _get_name() -> String:
	var proper_name: String = name.to_snake_case().capitalize()
	if value == "":
		return proper_name
	else:
		return "{name}: {val}".format({"name": proper_name, "val": value})
