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
	var _adjacent_units: Array[Unit] = []
	var _touching_unit: Unit
	var menu_items: Array[String] = []
	var pos: Vector2i = connected_unit.get_position()
	# Gets all adjacent units
	for unit in get_tree().get_nodes_in_group("units"):
		if not unit.is_ghost:
			var cursor_pos: Vector2i = (GenVars.cursor as Cursor).get_true_pos()
			if GenFunc.get_tile_distance(cursor_pos, unit.get_position()) == 0 \
					and not unit == self:
				_touching_unit = unit
			elif GenFunc.get_tile_distance(cursor_pos, unit.get_position()) == 1:
				_adjacent_units.append(unit)

	# Whether unit can attack.
	if _can_attack():
		menu_items.append("Attack")

	var movement: int = connected_unit.get_stat(Unit.stats.MOVEMENT)
	if movement > 0 and pos in connected_unit.get_raw_movement_tiles():
		if not _touching_unit:
			menu_items.append("Wait")

	for unit in _adjacent_units:
		if connected_unit.can_rescue(unit):
			menu_items.append("Rescue")
			break

	if connected_unit.traveler:
		menu_items.append("Drop")

	item_keys = menu_items
	return super()


func select_item(item: String) -> void:
	match item:
		"Attack":
			var weapon: Weapon = connected_unit.get_current_weapon()
			var min: int = weapon.min_range
			var max: int = weapon.max_range
			var is_enemy: Callable = func can_attack(unit: Unit):
				return not connected_unit.is_friend(unit)
			var attack_icon := Cursor.icons.ATTACK
			var selector := UnitSelector.new(connected_unit, min, max, is_enemy, attack_icon)
			var display: Callable = GenVars.map.display_highlighted_tiles
			var get_attack_tiles: Callable = connected_unit.get_current_attack_tiles
			var tiles: Array[Vector2i] = get_attack_tiles.call(connected_unit.get_unit_path()[-1])
			var tiles_node: Node2D = display.call(tiles, connected_unit, Map.tile_types.ATTACK)
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
			var display: Callable = GenVars.map.display_highlighted_tiles
			var get_adjacent_tiles: Callable = connected_unit.get_adjacent_tiles
			var current_pos: Vector2i = connected_unit.get_unit_path()[-1]
			var tiles: Array[Vector2i] = get_adjacent_tiles.call(current_pos, 1, 1)
			var tiles_node: Node2D = display.call(tiles, connected_unit, Map.tile_types.SUPPORT)
			var rescue: Callable = func(selected_unit: Unit) -> void:
				await connected_unit.move()
				await selected_unit.move(connected_unit.position)
				selected_unit.visible = false
				connected_unit.traveler = selected_unit
				connected_unit.wait()
				close()
			_select_map(selector, tiles_node, rescue)

		"Drop":
			var current_position: Vector2i = connected_unit.get_unit_path()[-1]
			connected_unit.traveler.position = current_position
			var tiles: Array[Vector2i] = connected_unit.traveler.get_raw_movement_tiles(1)
			tiles.erase(current_position)
			var tiles_node: Node2D = GenVars.map.display_tiles(tiles, Map.tile_types.SUPPORT)
			var condition: Callable = func(pos: Vector2i):
				return pos in tiles
			var selector := TileSelector.new(connected_unit, 1, 1, condition)
			var drop: Callable = func(dropped_tile: Vector2i) -> void:
				await connected_unit.move()
				connected_unit.traveler.visible = true
				connected_unit.traveler.position = connected_unit.position
				await connected_unit.traveler.move(dropped_tile)
				connected_unit.traveler = null
				connected_unit.wait()
				close()
			_select_map(selector, tiles_node, drop)


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


func _can_attack() -> bool:
	var pos: Vector2i = (GenVars.cursor as Cursor).get_true_pos()
	var current_tiles: Array[Vector2i] = connected_unit.get_current_attack_tiles(pos)
	var raw_tiles: Array[Vector2i] = connected_unit.get_raw_movement_tiles()
	var attack_tiles: Array[Vector2i] = connected_unit.get_all_attack_tiles()
	for unit in get_tree().get_nodes_in_group("units"):
		var faction: Faction = (unit as Unit).get_faction()
		var diplo_stance := connected_unit.get_faction().get_diplomacy_stance(faction)
		if diplo_stance == Faction.diplo_stances.ENEMY:
			if ((Vector2i(unit.position) in current_tiles and pos in raw_tiles) \
					or (pos == Vector2i(unit.position) and pos in attack_tiles)):
				return true
	return false



func _on_unit_death() -> void:
	close()
