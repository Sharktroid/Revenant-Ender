class_name TradeMenu
extends Control

const _ITEM_LABEL_PATH : String = ("res://ui/map_ui/map_menus/trade_menu/" +
		"trade_menu_item/trade_menu_item.")
const _ItemLabel = preload(_ITEM_LABEL_PATH + "gd")
const _ITEM_LABEL_SCENE: PackedScene = \
		preload(_ITEM_LABEL_PATH + "tscn")

var left_unit: Unit
var right_unit: Unit
var current_label: _ItemLabel
var selected_label: _ItemLabel
var empty_bar: _ItemLabel


func _ready() -> void:
	GameController.add_to_input_stack(self)
	_update()

	var hand := $SelectionHand as Sprite2D
	var tween: Tween = hand.create_tween()
	tween.set_loops()
	tween.set_speed_scale(60)
	tween.tween_interval(7)
	tween.tween_property(hand, "offset:x", -11, 9)
	tween.tween_interval(7)
	tween.tween_property(hand, "offset:x", -15, 9)


func _process(_delta: float) -> void:
	($SelectionHand as Sprite2D).position = current_label.global_position.round()


func receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		if selected_label:
			var old_item_node: ItemLabel = selected_label
			var new_item_node: ItemLabel = current_label
			var old_item_index: int = old_item_node.get_index()
			var new_item_index: int = new_item_node.get_index()
			var old_item: Item= old_item_node.item
			var new_item: Item= new_item_node.item
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
			if new_item_node == empty_bar:
				old_item_node.queue_free()
				empty_bar = null
			else:
				old_item_node.update()
				old_item_node.set_equip_status(old_item_unit)
			new_item_node.update()
			new_item_node.set_equip_status(new_item_unit)

			_reset()
		else:
			selected_label = current_label
			var selected_hand := $SelectedHand as Sprite2D
			selected_hand.visible = true
			selected_hand.position = selected_label.global_position.round()
			empty_bar = _ITEM_LABEL_SCENE.instantiate() as _ItemLabel
			empty_bar.parent_menu = self
			var new_parent: VBoxContainer = _get_other_parent(current_label)
			new_parent.add_child(empty_bar)
			_change_current_label(new_parent, new_parent.get_children().size() - 1)
	elif event.is_action_pressed("ui_cancel"):
		if selected_label:
			_change_current_label(selected_label.get_parent(), selected_label.get_index())
			_reset()
		else:
			queue_free()
			accept_event()
	elif event.is_action_pressed("up"):
		_change_current_label(current_label.get_parent(), current_label.get_index() - 1)
	elif event.is_action_pressed("down"):
		_change_current_label(current_label.get_parent(), current_label.get_index() + 1)
	elif event.is_action_pressed("left") or event.is_action_pressed("right"):
		var new_parent: VBoxContainer = _get_other_parent(current_label)
		_change_current_label(new_parent,
				mini(current_label.get_index(), new_parent.get_children().size()))


func _get_other_parent(label: ItemLabel) -> VBoxContainer:
	return (
			%RightItems if label.get_parent() == %LeftItems
			else  %LeftItems
	) as VBoxContainer


func _get_unit(label: ItemLabel) -> Unit:
	return left_unit if label.get_parent() == %LeftItems else right_unit


func _update() -> void:
	for child: Node in (%LeftItems.get_children() + %RightItems.get_children()):
		child.queue_free()
	current_label = null
	var add_items: Callable = func(unit: Unit, container: VBoxContainer) -> void:
		for item: Item in unit.items:
			var item_label := _ITEM_LABEL_SCENE.instantiate() as _ItemLabel
			item_label.item = item
			item_label.set_equip_status(unit)
			item_label.parent_menu = self
			if not current_label:
				current_label = item_label
			container.add_child(item_label)
	add_items.call(left_unit, %LeftItems)
	add_items.call(right_unit, %RightItems)


func _reset() -> void:
	selected_label = null
	($SelectedHand as Sprite2D).visible = false
	if empty_bar:
		empty_bar.queue_free()


func _change_current_label(parent: Node, index: int) -> void:
	current_label = parent.get_child(posmod(index, parent.get_children().size())) as _ItemLabel
