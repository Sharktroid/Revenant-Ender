class_name TradeMenu
extends Control

const ITEM_LABEL_SCENE: PackedScene = \
		preload("res://ui/map_ui/map_menus/trade_menu/trade_menu_item/trade_menu_item.tscn")

var left_unit: Unit
var right_unit: Unit
var current_label: ItemLabel


func _ready() -> void:
	var add_items: Callable = func(unit: Unit, container: VBoxContainer):
		for item: Item in unit.items:
			var item_label: ItemLabel = ITEM_LABEL_SCENE.instantiate()
			item_label.item = item
			item_label.set_equip_status(unit)
			item_label.parent_menu = self
			if not current_label:
				current_label = item_label
			container.add_child(item_label)
	add_items.call(left_unit, %"Left Items")
	add_items.call(right_unit, %"Right Items")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()
		accept_event()
	elif event.is_action_pressed("up"):
		_change_current_label(current_label.get_parent(), current_label.get_index() - 1)
	elif event.is_action_pressed("down"):
		_change_current_label(current_label.get_parent(), current_label.get_index() + 1)
	elif event.is_action_pressed("left") or event.is_action_pressed("right"):
		var new_parent: VBoxContainer = %"Left Items"
		if current_label.get_parent() == %"Left Items":
			new_parent = %"Right Items"
		_change_current_label(new_parent,
				mini(current_label.get_index(), new_parent.get_children().size()))


func _change_current_label(parent: Node, index: int) -> void:
	current_label = parent.get_child(posmod(index, parent.get_children().size()))
