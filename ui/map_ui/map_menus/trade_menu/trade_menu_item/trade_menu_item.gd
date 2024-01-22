extends ItemLabel

var parent_menu: TradeMenu


func _process(_delta: float) -> void:
	var label: Label = $Name
	if self == parent_menu.current_label:
		if label.has_theme_color_override("font_color"):
			label.remove_theme_color_override("font_color")
	else:
		if not label.has_theme_color_override("font_color"):
			label.add_theme_color_override("font_color", Color.GRAY)


func _on_mouse_entered() -> void:
	parent_menu.current_label = self
