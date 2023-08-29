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
	if movement > 0 and pos in connected_unit.raw_movement_tiles:
		var can_wait: Callable = func():
			if _touching_unit:
				var touching_faction: Faction = _touching_unit.get_faction()
				var get_touching_stance: Callable = touching_faction.get_diplomacy_stance
				var current_faction: Faction = connected_unit.get_faction()
				var stance: Faction.diplo_stances = get_touching_stance.call(current_faction)
				return stance in [Faction.diplo_stances.ALLY, Faction.diplo_stances.SELF]
			else:
				return true
		if can_wait.call():
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
			var is_enemy: Callable = func can_attack(unit: Unit):
				return not connected_unit.is_friend(unit)
			var min_range: int = weapon.min_range
			var max_range: int = weapon.max_range
			var controller := UnitSelector.new(connected_unit, min_range, max_range, is_enemy)
			caller.add_sibling(controller)
			connected_unit.display_current_attack_tiles(connected_unit.get_unit_path()[-1])
			visible = false
			var selected_unit = await controller.selected
			connected_unit.hide_current_attack_tiles()
			if selected_unit == null:
				visible = true
				grab_focus()
			else:
				connected_unit.move()
				await connected_unit.arrived
				await AttackHandler.combat(connected_unit, selected_unit)
				connected_unit.wait()
				close()

		"Wait":
			connected_unit.move()
			await connected_unit.arrived
			connected_unit.wait()
			close()

		"Rescue":
			var controller := UnitSelector.new(connected_unit, 1, 1, connected_unit.can_rescue)
			caller.add_sibling(controller)
			visible = false
			var display: Callable = GenVars.map.display_surrounding_tiles
			var rescue_tiles: Node2D = display.call(connected_unit, GenVars.map.tile_types.SUPPORT)
			var selected_unit: Unit = await controller.selected
			rescue_tiles.queue_free()
			if selected_unit == null:
				visible = true
				grab_focus()
			else:
				connected_unit.move()
				await connected_unit.arrived
				selected_unit.visible = false
				connected_unit.traveler = selected_unit
				connected_unit.wait()
				close()

		"Drop":
			var condition: Callable = func(pos: Vector2i):
				var terrain_cost: int = GenVars.map.get_terrain_cost(connected_unit.traveler, pos)
				return terrain_cost <= connected_unit.traveler.get_stat(Unit.stats.MOVEMENT)
			var controller := TileSelector.new(connected_unit, 1, 1, condition)
			caller.add_sibling(controller)
			visible = false
			var display: Callable = GenVars.map.display_surrounding_tiles
			var drop_tiles: Node2D = display.call(connected_unit, GenVars.map.tile_types.SUPPORT)
			var drop_pos = await controller.selected
			drop_tiles.queue_free()
			if drop_pos == null:
				visible = true
				grab_focus()
			else:
				connected_unit.move()
				await connected_unit.arrived
				connected_unit.traveler.visible = true
				connected_unit.traveler.position = drop_pos
				connected_unit.traveler = null
				connected_unit.wait()
				close()



func _can_attack() -> bool:
	var pos: Vector2i = (GenVars.cursor as Cursor).get_true_pos()
	for unit in get_tree().get_nodes_in_group("units"):
		var faction: Faction = (unit as Unit).get_faction()
		var diplo_stance := connected_unit.get_faction().get_diplomacy_stance(faction)
		if diplo_stance == Faction.diplo_stances.ENEMY:
			var current_tiles: Array[Vector2i] = connected_unit.get_current_attack_tiles(pos)
			var raw_tiles: Array[Vector2i] = connected_unit.get_raw_movement_tiles()
			var attack_tiles: Array[Vector2i] = connected_unit.get_all_attack_tiles()
			if ((Vector2i(unit.position) in current_tiles and pos in raw_tiles) \
					or (pos == Vector2i(unit.position) and pos in attack_tiles)):
				return true
	return false



func _on_unit_death() -> void:
	close()
