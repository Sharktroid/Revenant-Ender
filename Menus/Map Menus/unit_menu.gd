extends "res://Menus/Map Menus/base_map_menu.gd"

var connected_unit: Unit
var caller: SelectedUnitController
var _adjacent_units: Array[Unit]
var _touching_unit: Unit


func _enter_tree() -> void:
	items = get_menu_items()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close(true)
	else:
		super(event)


func close(return_to_caller: bool = false) -> void:
	super()
	GenVars.get_cursor().set_active(true)
	GenVars.get_cursor().connect_to(caller)
	if not return_to_caller:
		caller.close()


func get_menu_items() -> Array[String]:
	# Gets the items for the unit menu.
	_adjacent_units = []
	_touching_unit = null
	var menu_items: Array[String] = []
	var pos: Vector2i = connected_unit.get_position()
	# Gets all adjacent units
	for unit in get_tree().get_nodes_in_group("units"):
		if not unit.is_ghost:
			var unit_pos: Vector2i = unit.position
			if GenFunc.get_tile_distance(unit_pos, connected_unit.get_position()) == 0 \
					and not unit == self:
				_touching_unit = unit
			elif GenFunc.get_tile_distance(unit_pos, connected_unit.get_position()) == 1:
				_adjacent_units.append(unit)

	# Whether unit can attack.
	if _can_attack():
		menu_items.append("Attack")

	# Whether unit can capture.
	if "Capture" in connected_unit.skills:
		if _touching_unit \
				and GenVars.get_map().diplomacy[connected_unit.faction][_touching_unit.faction] == "Enemy" \
				and connected_unit.all_tags.BUILDING in _touching_unit.tags:
			menu_items.append("Capture")
	# Whether unit can wait.
	if connected_unit.get_movement() > 0 and pos in connected_unit.raw_movement_tiles:
		# Unit cannot wait on a non-building unit
		var touching_tags: Array[Unit.all_tags] = [Unit.all_tags.BUILDING]
		if _touching_unit:
			touching_tags = _touching_unit.tags
		if not (_touching_unit != null and _touching_unit != connected_unit and connected_unit.all_tags.BUILDING in touching_tags):
			menu_items.append("Wait")
	# Whether unit can creat other units.
	if "Produces" in connected_unit.skills:
		menu_items.append("Create")
	if "View Items" in connected_unit.skills:
		menu_items.append("Items")
	return menu_items


func _can_attack() -> bool:
	var pos: Vector2i = connected_unit.position
	for unit in get_tree().get_nodes_in_group("units"):
		if connected_unit.get_faction().get_diplomacy_stance((unit as Unit).get_faction()) == Faction.diplo_stances.ENEMY:
			if ((Vector2i(unit.position) in connected_unit.get_current_attack_tiles(pos) and pos in connected_unit.get_raw_movement_tiles()) \
					or (pos == Vector2i(unit.position) and pos in connected_unit.get_all_attack_tiles())):
				return true
	return false


func _on_button_pressed(button: Button) -> void:
	match (button.text+":").split(":")[0]:
		"Attack":
			set_active(false)
			var controller := UnitSelector.new(connected_unit)
			add_child(controller)
			var selected_unit = await controller.selected
			if selected_unit == null:
				set_active(true)
			else:
				connected_unit.move()
				await AttackHandler.combat(connected_unit, selected_unit)
				connected_unit.wait()
				close()

#		"Create":
#			var pos: Vector2 = GenVars.get_cursor().get_true_pos() + Vector2(16, -8)
#			var menu = GenFunc.create_map_menu(self, "Create", skills["Produces"], pos)
#			GenVars.get_level_controller().get_node("UILayer/Unit Menu").set_active(false)
#			await menu.menu_closed
#			return false

		"Wait":
			connected_unit.move()
			set_active(false)
			await connected_unit.arrived
			connected_unit.wait()
			close()

		"Capture":
			if _touching_unit:
				connected_unit.move()
				await self.arrived
				var reduction: float = -connected_unit.get_current_health() # Placeholder value; should be negative.
				if _touching_unit.get_current_health() + reduction:
					_touching_unit.change_faction(connected_unit.faction)
				_touching_unit.add_current_health(reduction)
				connected_unit.wait()
			else:
				push_error("Capturable object not found")

		var item:
			push_error('"%s" is not a valid action' % item)
