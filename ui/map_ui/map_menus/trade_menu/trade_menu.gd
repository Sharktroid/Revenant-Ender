class_name TradeMenu
extends Control

const ITEM_LABEL_SCENE: PackedScene = preload("res://ui/map_ui/item_label/item_label.tscn")

var left_unit: Unit
var right_unit: Unit


func _ready() -> void:
	var add_items: Callable = func(unit: Unit, container: VBoxContainer):
		for item: Item in unit.items:
			var node: ItemLabel = ITEM_LABEL_SCENE.instantiate()
			node.item = item
			node.set_equip_status(unit)
			container.add_child(node)
	add_items.call(left_unit, %"Left Items")
	add_items.call(right_unit, %"Right Items")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()
		accept_event()
