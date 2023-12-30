extends MapMenuItem

var item: Item


func _init(connected_item: Item) -> void:
	item = connected_item

func _ready() -> void:
	name = item.name
	var icon := TextureRect.new()
	icon.texture = item.icon
	add_child(icon)
	super()
