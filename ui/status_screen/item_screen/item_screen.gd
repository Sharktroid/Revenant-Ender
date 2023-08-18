extends Panel

var observing_unit: Unit


func update() -> void:
	for child in $"Item Label Container".get_children():
		for grandchild in child.get_children():
			grandchild.queue_free()
	for item in observing_unit.items:
		var equip_status := Control.new()
		if item == observing_unit.get_current_weapon():
			equip_status = Label.new()
			equip_status.text = "W"
			equip_status.add_theme_color_override("font_color", Color.ROYAL_BLUE)
		$"Item Label Container/Equip Status".add_child(equip_status)

		var icon := TextureRect.new()
		icon.texture = item.icon
		$"Item Label Container/Icons".add_child(icon)

		var item_name := Label.new()
		item_name.text = item.name
		if not observing_unit.can_use_weapon(item):
			item_name.theme_type_variation = "GreyLabel"
		$"Item Label Container/Names".add_child(item_name)

		var current_uses := Label.new()
		current_uses.text = str(item.current_uses)
		current_uses.theme_type_variation = "BlueLabel"
		$"Item Label Container/Current Uses".add_child(current_uses)

		var separator := Label.new()
		separator.text = "/"
		$"Item Label Container/Separators".add_child(separator)

		var max_uses := Label.new()
		max_uses.text = str(item.max_uses)
		max_uses.theme_type_variation = "BlueLabel"
		$"Item Label Container/Max Uses".add_child(max_uses)
