class_name TradeMenu
extends Control

signal completed(action_performed: bool)

const ITEM_GROUP: StringName = &"trade_menu_item_group"

var current_label: TradeMenuItem

var _left_unit: Unit
var _right_unit: Unit
var _selected_label: TradeMenuItem
var _empty_bar: TradeMenuItem
var _action_performed: bool = false


func _ready() -> void:
	_update()


func _process(_delta: float) -> void:
	($SelectionHand as Sprite2D).position = current_label.global_position.round()


func _exit_tree() -> void:
	completed.emit(_action_performed)


static func instantiate(left: Unit, right: Unit) -> TradeMenu:
	var scene := (
		preload("res://ui/map_ui/map_menus/trade_menu/trade_menu.tscn").instantiate() as TradeMenu
	)
	scene._left_unit = left
	scene._right_unit = right
	return scene


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		if _selected_label != current_label:
			_action_performed = true
			if _selected_label:
				var old_item_node: TradeMenuItem = _selected_label
				var new_item_node: TradeMenuItem = current_label
				var old_item: Item = old_item_node.item
				var new_item: Item = new_item_node.item
				var old_item_index: int = old_item_node.get_index()
				var new_item_index: int = new_item_node.get_index()
				var old_item_unit: Unit = _get_unit(old_item_node)
				var new_item_unit: Unit = _get_unit(new_item_node)

				if new_item == null:
					old_item_unit.items.erase(old_item)
					new_item_unit.items.append(old_item)
				else:
					old_item_unit.items[old_item_index] = new_item
					new_item_unit.items[new_item_index] = old_item
				old_item_node.item = new_item
				new_item_node.item = old_item
				if new_item_node == _empty_bar:
					old_item_node.queue_free()
					_empty_bar = null
				_reset()
			else:
				_selected_label = current_label
				var selected_hand := $SelectedHand as Sprite2D
				selected_hand.visible = true
				selected_hand.position = _selected_label.global_position.round()
				_empty_bar = TradeMenuItem.instantiate(
					null,
					_left_unit if current_label.get_parent() == %LeftItems else _right_unit,
					self
				)
				var new_parent: VBoxContainer = _get_other_parent(current_label)
				new_parent.add_child(_empty_bar)
				_change_current_label(new_parent, new_parent.get_children().size() - 1)
			for item: TradeMenuItem in %LeftItems.get_children() + %RightItems.get_children():
				item.update()
	elif event.is_action_pressed("back"):
		if _selected_label:
			_change_current_label(_selected_label.get_parent(), _selected_label.get_index())
			_reset()
		else:
			queue_free()
			accept_event()
	elif event.is_action_pressed("up"):
		_change_current_label(current_label.get_parent(), current_label.get_index() - 1)
	elif event.is_action_pressed("down"):
		_change_current_label(current_label.get_parent(), current_label.get_index() + 1)
	elif event.is_action_pressed("left") or event.is_action_pressed("right"):
		if _get_other_parent(current_label).get_child_count() > 0:
			var new_parent: VBoxContainer = _get_other_parent(current_label)
			_change_current_label(
				new_parent, mini(current_label.get_index(), new_parent.get_children().size())
			)


func _get_other_parent(label: ItemLabel) -> VBoxContainer:
	return (%RightItems if label.get_parent() == %LeftItems else %LeftItems) as VBoxContainer


func _get_unit(label: ItemLabel) -> Unit:
	return _left_unit if label.get_parent() == %LeftItems else _right_unit


func _update() -> void:
	get_tree().call_group(ITEM_GROUP, "queue_free")
	current_label = null
	_add_items(_left_unit, %LeftItems as VBoxContainer)
	_add_items(_right_unit, %RightItems as VBoxContainer)


func _reset() -> void:
	_selected_label = null
	($SelectedHand as Sprite2D).visible = false
	if _empty_bar:
		_empty_bar.queue_free()


func _change_current_label(parent: Node, index: int) -> void:
	current_label = parent.get_child(posmod(index, parent.get_children().size())) as TradeMenuItem


func _add_items(unit: Unit, container: VBoxContainer) -> void:
	for item: Item in unit.items:
		var item_label := TradeMenuItem.instantiate(item, unit, self)
		if not current_label:
			current_label = item_label
		container.add_child(item_label)
