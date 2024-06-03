class_name MapMenuItem
extends HelpContainer

var value: String:
	set(new_value):
		value = new_value
		_update()

var _label := Label.new()


func _init() -> void:
	selectable = false
	add_child(_label)
	mouse_entered.connect(_on_mouse_entered)


func _enter_tree() -> void:
	_update()
	select()
	if not self == _get_parent_menu().get_current_item_node():
		deselect()


func select() -> void:
	if _label.has_theme_color_override("font_color"):
		_label.remove_theme_color_override("font_color")


func deselect() -> void:
	if not _label.has_theme_color_override("font_color"):
		_label.add_theme_color_override("font_color", Color.GRAY)


func _get_parent_menu() -> MapMenu:
	return get_parent().get_parent()


func _on_mouse_entered() -> void:
	super()
	if GameController.get_current_input_node() == _get_parent_menu():
		_get_parent_menu().set_current_item_node(self)


func _update() -> void:
	var proper_name: String = name.to_snake_case().capitalize()
	_label.text = (
		proper_name as String
		if value == ""
		else "{name}: {val}".format({"name": proper_name, "val": value})
	)
