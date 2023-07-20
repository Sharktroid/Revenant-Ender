extends Button

var item: String
var parent_menu: MapMenu


func _pressed():
	parent_menu.select_item(item)
