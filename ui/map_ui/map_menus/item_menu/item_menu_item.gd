extends MapMenuItem

var _item: Item


func _init(item: Item) -> void:
	_item = item

func _ready() -> void:
	name = _item.name
	var icon := TextureRect.new()
	icon.texture = _item.icon
	add_child(icon)
	super()
