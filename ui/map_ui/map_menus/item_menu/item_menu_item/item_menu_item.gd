extends MapMenuItem

var item: Item


func _init(connected_item: Item) -> void:
	item = connected_item
	name = item.resource_name
	var icon := TextureRect.new()
	icon.texture = item.get_icon()
	add_child(icon)
	help_description = item.get_description()
	super()
