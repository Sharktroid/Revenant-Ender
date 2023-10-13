extends MapMenuItem

var item: Item


func _init(item: Item) -> void:
	self.item = item

func _ready() -> void:
	name = item.name
	var icon := TextureRect.new()
	icon.texture = item.icon
	add_child(icon)
	super()
