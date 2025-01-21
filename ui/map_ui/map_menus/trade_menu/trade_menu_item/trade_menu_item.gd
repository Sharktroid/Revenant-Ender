class_name TradeMenuItem
extends ItemLabel

var item: Item:
	set(value):
		_item = value
	get:
		return _item
var _parent_menu: TradeMenu


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
	scene._parent_menu = parent
	if new_item:
		scene.item = new_item
	scene._unit = unit
	scene.add_to_group(TradeMenu.ITEM_GROUP)
	return scene


func update() -> void:
	_update()


func _update() -> void:
	for child: Control in get_children() as Array[Control]:
		child.visible = (_item != null)
	if _item != null:
		super()


func _on_mouse_entered() -> void:
	if HelpPopupController.is_active():
		super()
	else:
		_parent_menu.current_label = self
