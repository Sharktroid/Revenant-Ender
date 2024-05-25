extends "res://ui/map_ui/map_menus/item_menu/item_menu_item/item_menu_item.gd"


func _on_mouse_entered() -> void:
	super()
	_get_parent_menu().set_current_item_node(self)
