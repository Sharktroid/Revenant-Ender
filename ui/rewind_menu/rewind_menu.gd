class_name RewindMenu
extends Panel

## The extra actions above and below the currently selected action.
const EXTRA_ACTIONS: int = 4

var _actions: Array[Dictionary] = []
var _tween: Tween
var _index: float:
	set = _set_index

@onready var _action_scroll_container := $ActionScrollContainer as ScrollContainer
@onready var _action_v_box := %ActionVBox as VBoxContainer
@onready var _vertical_spacing: int = _action_v_box.get_theme_constant(&"separation")
@onready var _full_cell_size: int = 16 + _vertical_spacing


func _ready() -> void:
	for index: int in EXTRA_ACTIONS:
		_action_v_box.add_child(_create_spacer())
	for index: int in _actions.size():
		var panel_container := PanelContainer.new()
		var stylebox := StyleBoxFlat.new()
		stylebox.bg_color = _get_color(index)
		stylebox.bg_color.a = 0.5
		panel_container.add_theme_stylebox_override(&"panel", stylebox)

		var h_box := HBoxContainer.new()
		var unit_control := Control.new()
		unit_control.custom_minimum_size.x = 16
		if _actions[index][&"unit_sprite"]:
			unit_control.add_child((_actions[index][&"unit_sprite"] as UnitSprite).duplicate())
		h_box.add_child(unit_control)

		var label := Label.new()
		label.text = str(_actions[index][&"name"])
		h_box.add_child(label)
		panel_container.add_child(h_box)
		_action_v_box.add_child(panel_container)
	for index: int in EXTRA_ACTIONS + 1:
		_action_v_box.add_child(_create_spacer())
	_action_scroll_container.custom_minimum_size.y = (
		16 + _full_cell_size * ((EXTRA_ACTIONS + 1) * 2)
	)
	(%MarginContainer as MarginContainer).add_theme_constant_override(
		&"margin_top", _full_cell_size
	)
	await get_tree().process_frame
	_index = _actions.size() - 1


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"back") or event.is_action_pressed(&"rewind"):
		MapController.map.rewind_load(_actions.size() - 1)
		queue_free()
	elif event.is_action_pressed(&"select"):
		MapController.map.rewind_load(roundi(_index), true)
		queue_free()
	elif event.is_action_pressed(&"select"):
		if (
			event is InputEventMouseButton
			and _action_scroll_container.get_rect().has_point(get_global_mouse_position())
		):
			var offset_position: Vector2 = get_global_mouse_position()
			offset_position.y += (
				_action_scroll_container.scroll_vertical - _full_cell_size * 3 - _vertical_spacing
			)
			for child: PanelContainer in _get_panel_containers():
				if child.get_rect().has_point(offset_position):
					_tween_index(_get_panel_containers().find(child))

	elif event.is_action_pressed(&"scroll_up", true):
		_tween_index(floori(_index) - 1)
	elif event.is_action_pressed(&"scroll_down", true):
		_tween_index(ceili(_index) + 1)
	elif event.is_action_pressed(&"ui_home", true):
		_tween_index(0)
	elif event.is_action_pressed(&"ui_end", true):
		_tween_index(_actions.size() - 1)
	elif event.is_action_pressed(&"ui_page_up", true):
		_tween_index(floori(_index) - (EXTRA_ACTIONS + 1))
	elif event.is_action_pressed(&"ui_page_down", true):
		_tween_index(ceili(_index) + EXTRA_ACTIONS + 1)


func _set_index(value: float) -> void:
	_index = clampf(value, 0, _actions.size() - 1)
	_action_scroll_container.scroll_vertical = roundi(_index * _full_cell_size)
	for index: int in _get_panel_containers().size():
		var child := _get_panel_containers()[index] as PanelContainer
		child.modulate.a = clampf(-absf(index - _index) + EXTRA_ACTIONS + 1, 0, 1)
		(child.get_theme_stylebox(&"panel") as StyleBoxFlat).bg_color = _get_color(index)
	var current_action: Dictionary[StringName, Variant] = _actions[_index]
	(%TurnNumber as Label).text = str(current_action[&"_current_turn"])
	var filter: Callable = func(unit: Dictionary[StringName, Variant]) -> int:
		return (
			not unit[&"waiting"]
			and unit[&"_faction_id"] == current_action[&"_current_faction_index"]
		)
	var units := (
		(current_action[&"units"] as Dictionary[String, Dictionary]).values() as Array[Dictionary]
	)
	(%ReadyUnitsNumber as Label).text = str(units.filter(filter).size())


static func instantiate(actions: Array[Dictionary]) -> RewindMenu:
	const PACKED_SCENE: PackedScene = preload("res://ui/rewind_menu/rewind_menu.tscn")
	var scene := PACKED_SCENE.instantiate() as RewindMenu
	scene._actions = actions
	return scene


func _get_color(index: int) -> Color:
	var color: Color = _get_faction_color().lerp(Color.BLACK, absf(index - _index))
	color.a = 0.5
	return color


func _get_faction_color() -> Color:
	match (_actions[_index][&"current_faction"] as Faction).color:
		Faction.Colors.BLUE:
			return Color.BLUE
		Faction.Colors.RED:
			return Color.RED
	return Color.BLUE


func _create_spacer() -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 16
	return spacer


func _get_panel_containers() -> Array[PanelContainer]:
	var panel_containers: Array[PanelContainer]
	panel_containers.assign(
		_action_v_box.get_children().filter(
			func(child: Node) -> bool: return child is PanelContainer
		)
	)
	return panel_containers


func _tween_index(value: float) -> void:
	if _tween:
		_tween.stop()
	_tween = create_tween()
	_tween.tween_property(self, ^"_index", clampf(value, 0, _actions.size() - 1), 1.0 / 15)
	await _tween.finished
	MapController.map.rewind_load(roundi(_index))
