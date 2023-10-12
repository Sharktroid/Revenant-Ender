extends MapMenu

var _menu_item_node: GDScript = load("res://ui/map_ui/map_menus/item_menu/item_menu_item.gd")
var connected_unit: Unit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for item in connected_unit.items:
		var item_node: HelpContainer = _menu_item_node.new(item)
		item_node.help_description = item.get_description()
		$Items.add_child(item_node)
	super()


func close() -> void:
	super()
	parent_menu.grab_focus()
	parent_menu.visible = true
