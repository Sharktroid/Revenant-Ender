extends MapMenu

var connected_unit: Unit
var caller: SelectedUnitController
var _adjacent_units: Array[Unit]
var _touching_unit: Unit


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
	_adjacent_units = []
	_touching_unit = null
	var menu_items: Array[String] = []
	var pos: Vector2i = connected_unit.get_position()
	# Gets all adjacent units
	for unit in get_tree().get_nodes_in_group("units"):
		if not unit.is_ghost:
			var cursor_pos: Vector2i = (GenVars.cursor as Cursor).get_true_pos()
			if GenFunc.get_tile_distance(cursor_pos, connected_unit.get_position()) == 0 \
					and not unit == self:
				_touching_unit = unit
			elif GenFunc.get_tile_distance(cursor_pos, connected_unit.get_position()) == 1:
				_adjacent_units.append(unit)

	# Whether unit can attack.
	if _can_attack():
		menu_items.append("Attack")

	# Whether unit can capture.
#	if "Capture" in connected_unit.skills:
#		var faction_diplo GenVars.map.diplomacy[connected_unit.faction]
#		if _touching_unit \
#				and faction_diplo[_touching_unit.faction] == "Enemy" \
#				and connected_unit.all_tags.BUILDING in _touching_unit.tags:
#			menu_items.append("Capture")
	# Whether unit can wait.
	var movement: int = connected_unit.get_stat(Unit.stats.MOVEMENT)
	if movement > 0 and pos in connected_unit.raw_movement_tiles:
		# Unit cannot wait on a non-building unit
#		var touching_tags: Array[Unit.all_tags] = [Unit.all_tags.BUILDING]
#		if _touching_unit:
#			touching_tags = _touching_unit.tags
		if _touching_unit == null:
			menu_items.append("Wait")
	# Whether unit can creat other units.
#	if "Produces" in connected_unit.skills:
#		menu_items.append("Create")
#	if "View Items" in connected_unit.skills:
#		menu_items.append("Items")
	item_keys = menu_items
	return super()


func select_item(item: String) -> void:
	match item:
		"Attack":
			var controller := UnitSelector.new(connected_unit)
			caller.add_sibling(controller)
			visible = false
			var selected_unit = await controller.selected
			if selected_unit == null:
				visible = true
				grab_focus()
			else:
				connected_unit.move()
				await connected_unit.arrived
				await AttackHandler.combat(connected_unit, selected_unit)
				connected_unit.wait()
				close()

#		"Create":
#			var pos: Vector2 = GenVars.cursor.get_true_pos() + Vector2(16, -8)
#			var menu = GenFunc.create_map_menu(self, "Create", skills["Produces"], pos)
#			GenVars.map_controller.get_node("UILayer/Unit Menu").set_active(false)
#			await menu.menu_closed
#			return false

		"Wait":
			connected_unit.move()
			await connected_unit.arrived
			connected_unit.wait()
			close()

		"Capture":
			if _touching_unit:
				connected_unit.move()
				await self.arrived
				# Placeholder value; should be negative.
				var reduction: float = -connected_unit.get_current_health()
				if _touching_unit.get_current_health() + reduction:
					_touching_unit.change_faction(connected_unit.faction)
				_touching_unit.add_current_health(reduction)
				connected_unit.wait()
			else:
				push_error("Capturable object not found")

		_: push_error('"%s" is not a valid action' % item)


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
