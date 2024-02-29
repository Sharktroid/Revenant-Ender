extends MapMenuItem

var item: Item


func _init(connected_item: Item) -> void:
	item = connected_item
	name = item.name
	var icon := TextureRect.new()
	icon.texture = item.icon
	add_child(icon)
