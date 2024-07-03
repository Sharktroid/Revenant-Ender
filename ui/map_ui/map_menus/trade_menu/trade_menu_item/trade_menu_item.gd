class_name TradeMenuItem
extends ItemLabel

var parent_menu: TradeMenu


func _init() -> void:
	selectable = false
	custom_minimum_size.y = 16
	for child: Control in get_children() as Array[Control]:
		child.visible = false


static func instantiate(
	new_item: Item = null, unit: Unit = null, parent: TradeMenu = null
) -> TradeMenuItem:
	const PACKED_SCENE: PackedScene = preload(
		"res://ui/map_ui/map_menus/trade_menu/trade_menu_item/trade_menu_item.tscn"
	)
	var scene := PACKED_SCENE.instantiate() as TradeMenuItem
	scene.parent_menu = parent
	if new_item:
		scene.item = new_item
		scene.set_equip_status(unit)
	scene.add_to_group(TradeMenu.ITEM_GROUP)
	return scene


func update() -> void:
	for child: Control in get_children() as Array[Control]:
		child.visible = (item != null)
	if item != null:
		super()


func _on_mouse_entered() -> void:
	parent_menu.current_label = self
