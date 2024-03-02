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


func _process(_delta: float) -> void:
	if self == _get_parent_menu().get_current_item_node():
		if _label.has_theme_color_override("font_color"):
			_label.remove_theme_color_override("font_color")
	else:
		if not _label.has_theme_color_override("font_color"):
			_label.add_theme_color_override("font_color", Color.GRAY)


func set_text(text: String) -> void:
	_label.text = text


func _get_parent_menu() -> MapMenu:
	return get_parent().get_parent()


func _on_mouse_entered() -> void:
	super()
	_get_parent_menu().set_current_item_node(self)


func _update() -> void:
	if value == "":
		_label.text = name
	else:
		_label.text = "%s: %s" % [name, value]
