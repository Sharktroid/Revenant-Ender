extends Label

var item: String
var parent_menu: MapMenu
var update_text: Callable = func(): pass


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	mouse_entered.connect(_on_mouse_entered)


func _process(_delta: float) -> void:
	if self == parent_menu.get_current_item_node():
		if not has_theme_color_override("font_color"):
			add_theme_color_override("font_color", Color.GRAY)
	else:
		if has_theme_color_override("font_color"):
			remove_theme_color_override("font_color")


func _on_mouse_entered() -> void:
	parent_menu.set_current_item_node(self)
