extends MapMenu

var connected_unit: Unit
var caller: SelectedUnitController


func _enter_tree() -> void:
	connected_unit.tree_exited.connect(_on_unit_death)


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close(true)
	else:
		super(event)


func close(return_to_caller: bool = false) -> void:
	queue_free()
	GenVars.cursor.enable()
	if return_to_caller:
		caller.set_focus_mode(Control.FOCUS_ALL)
		caller.grab_focus()
	else:
		caller.close()


func get_items() -> Dictionary:
	# Gets the items for the unit menu.
	var pos: Vector2i = _get_current_position()
	var movement: int = connected_unit.get_stat(Unit.stats.MOVEMENT)
	var raw_movement_tiles: Array[Vector2i] = connected_unit.get_raw_movement_tiles()
	_items = {
		Attack = false,
		Wait = false,
		Rescue = false,
		Drop = false,
	}
	if GenVars.cursor.get_true_pos() in raw_movement_tiles:
		_items.Wait = movement > 0 and pos in raw_movement_tiles
		_items.Drop = connected_unit.traveler != null
		# Gets all adjacent units
		for unit in get_tree().get_nodes_in_group("units"):
			if not unit.is_ghost:
				var cursor_pos: Vector2i = (GenVars.cursor as Cursor).get_true_pos()
				if GenFunc.get_tile_distance(cursor_pos, unit.get_position()) == 0 \
						and not unit == connected_unit:
					# Units occupying the same tile
					if unit != connected_unit:
						_items.Wait = false
				elif GenFunc.get_tile_distance(cursor_pos, unit.get_position()) == 1:
					# Adjacent units
					if connected_unit.is_friend(unit):
						if not unit.traveler:
							if connected_unit.can_rescue(unit):
								_items.Rescue = true
				if _can_attack(unit):
					_items.Attack = true
	else:
		if GenVars.cursor.get_hovered_unit() and _can_attack(GenVars.cursor.get_hovered_unit()):
			_items.Attack = true
	return super()


func select_item(item: String) -> void:
	match item:
		"Attack":
			var weapon: Weapon = connected_unit.get_current_weapon()
			var selector := UnitSelector.new(connected_unit, weapon.min_range, weapon.max_range,
					_can_attack, Cursor.icons.ATTACK)
			var tiles: Array[Vector2i] = connected_unit.get_current_attack_tiles(
					connected_unit.get_unit_path()[-1])
			var tiles_node: Node2D = GenVars.map.display_highlighted_tiles(tiles, connected_unit,
					Map.tile_types.ATTACK)
			var attack: Callable = func(selected_unit: Unit) -> void:
				await connected_unit.move()
				await AttackHandler.combat(connected_unit, selected_unit)
				connected_unit.wait()
				close()
			_select_map(selector, tiles_node, attack)

		"Wait":
			await connected_unit.move()
			connected_unit.wait()
			close()

		"Rescue":
			var selector := UnitSelector.new(connected_unit, 1, 1, connected_unit.can_rescue)
			var tiles: Array[Vector2i] = connected_unit.get_adjacent_tiles(
					connected_unit.get_unit_path()[-1], 1, 1)
			var tiles_node: Node2D = GenVars.map.display_highlighted_tiles(tiles, connected_unit,
					Map.tile_types.SUPPORT)
			var rescue: Callable = func(selected_unit: Unit) -> void:
				await connected_unit.move()
				await selected_unit.move(connected_unit.position)
				selected_unit.visible = false
				connected_unit.traveler = selected_unit
				connected_unit.wait()
				close()
			_select_map(selector, tiles_node, rescue)

		"Drop":
			var traveler: Unit = connected_unit.traveler
			traveler.position = _get_current_position()
			var tiles_node: Node2D = GenVars.map.display_tiles(_get_drop_tiles(),
					Map.tile_types.SUPPORT)
			var drop: Callable = func(dropped_tile: Vector2i) -> void:
				await connected_unit.move()
				traveler.visible = true
				traveler.position = connected_unit.position
				connected_unit.traveler = null
				await traveler.move(dropped_tile)
				connected_unit.wait()
				close()
			_select_map(TileSelector.new(connected_unit, 1, 1, _can_drop), tiles_node, drop)


func _select_map(selector: BaseSelector, tiles_node: Node2D, selected: Callable,
		canceled: Callable = func(): pass) -> void:
	caller.add_sibling(selector)
	visible = false
	var selection = await selector.selected
	tiles_node.queue_free()
	if selection == null:
		canceled.call()
		visible = true
		grab_focus()
	else:
		selected.call(selection)


func _can_attack(unit: Unit) -> bool:
	var pos: Vector2i = _get_current_position()
	var current_tiles: Array[Vector2i] = connected_unit.get_current_attack_tiles(pos)
	var faction: Faction = (unit as Unit).get_faction()
	var diplo_stance := connected_unit.get_faction().get_diplomacy_stance(faction)
	if diplo_stance == Faction.diplo_stances.ENEMY and Vector2i(unit.position) in current_tiles:
		return true
	return false


func _can_drop(pos: Vector2i) -> bool:
	return pos in _get_drop_tiles()


func _get_current_position() -> Vector2i:
	return connected_unit.get_unit_path()[-1]


func _get_drop_tiles() -> Array[Vector2i]:
	var traveler: Unit = connected_unit.traveler
	var tiles: Array[Vector2i] = []
	for tile in connected_unit.get_adjacent_tiles(_get_current_position(), 1, 1):
		var cost: int = GenVars.map.get_terrain_cost(traveler, tile)
		var movement: int = traveler.get_stat(Unit.stats.MOVEMENT)
		if cost <= movement:
			tiles.append(tile)
	return tiles


func _on_unit_death() -> void:
	close()
