class_name UnitMenu
extends MapMenu

var connected_unit: Unit
var caller: SelectedUnitController
var actionable: bool = true

var _canto: bool


func _init() -> void:
	_to_center = true


func _enter_tree() -> void:
	connected_unit.tree_exited.connect(_on_unit_death)
	update()
	current_item_index = 0
	var visible_items: bool = false
	for i: MapMenuItem in _get_item_nodes():
		if i.visible:
			visible_items = true
			break
	reset_size.call_deferred()
	if not visible_items:
		close(true)
	else:
		super()


static func instantiate(
	new_offset: Vector2, parent: MapMenu, unit_controller: SelectedUnitController, unit: Unit
) -> MapMenu:
	const PACKED_SCENE = preload("res://ui/map_ui/map_menus/unit_menu/unit_menu.tscn")
	var scene: MapMenu = _base_instantiate(PACKED_SCENE, new_offset, parent, unit_controller, unit)
	return scene


func receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)
		close(true)
	else:
		super(event)


func close(return_to_caller: bool = false) -> void:
	if not actionable:
		_check_canto()
	queue_free()
	if not (return_to_caller and actionable):
		caller.close()
	if _canto:
		CantoController.new.call_deferred(connected_unit)
	CursorController.enable.call_deferred()


static func get_displayed_items(unit: Unit) -> Dictionary:
	var enabled_items: Dictionary={
		Attack = false,
		Wait = false,
		Trade = false,
		Rescue = false,
		Take = false,
		Drop = false,
		Give = false,
		Exchange = false,
		Items = false,
	}
	if CursorController.map_position in unit.get_actionable_movement_tiles():
		enabled_items.Wait = unit.get_movement() > 0
		enabled_items.Drop = unit.traveler != null and _get_drop_tiles(unit).size() > 0
		enabled_items.Items = unit.items.size() > 0
		# Gets all adjacent units
		for adjacent_unit: Unit in MapController.map.get_units():
			if adjacent_unit != unit and adjacent_unit.visible == true:
				if (
					Utilities.get_tile_distance(CursorController.map_position, adjacent_unit.get_position())
					== 1
				):
					# Adjacent units
					if unit.is_friend(adjacent_unit):
						if unit.items.size() > 0 and adjacent_unit.items.size() > 0:
							enabled_items.Trade = true
						if adjacent_unit.traveler:
							if unit.traveler:
								enabled_items.Exchange = true
							else:
								enabled_items.Take = true
						else:
							if unit.traveler:
								enabled_items.Give = true
							elif unit.can_rescue(adjacent_unit):
								enabled_items.Rescue = true
				if _can_attack(unit, adjacent_unit):
					enabled_items.Attack = true
	else:
		if CursorController.get_hovered_unit() and _can_attack(unit, CursorController.get_hovered_unit()):
			enabled_items.Attack = true
	return enabled_items


func update() -> void:
	# Gets the items for the unit menu.
	var enabled_items: Dictionary = UnitMenu.get_displayed_items(connected_unit)
	var previous_node: MapMenuItem = get_current_item_node()
	for node: MapMenuItem in _get_item_nodes():
		node.visible = enabled_items[node.name]
	if previous_node.visible:
		set_current_item_node(previous_node)
	else:
		previous_node.selected = false
		current_item_index = 0
	reset_size()
	update_position()


func select_item(item: MapMenuItem) -> void:
	match item.name:
		"Attack":
			var selector := AttackSelector.new(
				connected_unit,
				connected_unit.get_min_range(),
				connected_unit.get_max_range(),
				func(unit: Unit) -> bool: return UnitMenu._can_attack(connected_unit, unit),
				CursorController.Icons.ATTACK
			)
			_select_map(selector, Node2D.new(), _attack)

		"Wait":
			_wait()

		"Trade":
			var selector := UnitSelector.new(connected_unit, 1, 1, connected_unit.is_friend)
			_select_map(selector, _display_adjacent_support_tiles(), _trade)

		"Items":
			var menu := ItemMenu.instantiate(offset, self, connected_unit)
			MapController.get_ui().add_child(menu)
			visible = false

		"Rescue":
			var selector := UnitSelector.new(connected_unit, 1, 1, connected_unit.can_rescue)
			_select_map(selector, _display_adjacent_support_tiles(), _rescue)

		"Drop":
			var tiles_node: Node2D = (MapController.map as Map).display_tiles(
				UnitMenu._get_drop_tiles(connected_unit), Map.TileTypes.SUPPORT
			)
			var tile_selector := TileSelector.new(
				connected_unit,
				1,
				1,
				_can_drop,
				CursorController.Icons.NONE,
				AudioPlayer.SoundEffects.BATTLE_SELECT
			)
			_select_map(tile_selector, tiles_node, _drop)

		"Take":
			_select_map(
				UnitSelector.new(connected_unit, 1, 1, _can_take),
				_display_adjacent_support_tiles(),
				_take
			)

		"Give":
			_select_map(
				UnitSelector.new(connected_unit, 1, 1, _can_give),
				_display_adjacent_support_tiles(),
				_give
			)

		"Exchange":
			_select_map(
				UnitSelector.new(connected_unit, 1, 1, _can_take),
				_display_adjacent_support_tiles(),
				_exchange
			)
	super(item)


func unactionable() -> void:
	actionable = false
	await connected_unit.move()


func _play_select_sound_effect(item: MapMenuItem) -> void:
	match item.name:
		"Wait":
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.BATTLE_SELECT)
		_:
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_SELECT)


func _check_canto() -> void:
	if connected_unit.get_skills().any(func(skill: Skill) -> bool: return skill is Canto):
		_canto = true
	else:
		connected_unit.wait()


func _select_map(
	selector: Selector,
	tiles_node: Node2D,
	selected: Callable,
	canceled: Callable = func() -> void: pass
) -> void:
	caller.add_sibling(selector)
	visible = false
	if selector is UnitSelector:
		var selection: Unit = await (selector as UnitSelector).selected
		if selection == null:
			canceled.call()
			visible = true
		else:
			selected.call(selection)
	else:
		var selection: Vector2 = await (selector as TileSelector).selected
		if selection == Vector2.INF:
			canceled.call()
			visible = true
		else:
			selected.call(selection)
	tiles_node.queue_free()


static func _can_attack(unit: Unit, adjacent_unit: Unit) -> bool:
	var current_tiles: Array[Vector2i] = unit.get_current_attack_tiles(
		unit.get_path_last_pos(), true
	)
	var diplo_stance: Faction.DiplomacyStances = unit.faction.get_diplomacy_stance(
		adjacent_unit.faction
	)
	return (
		diplo_stance == Faction.DiplomacyStances.ENEMY and Vector2i(adjacent_unit.position) in current_tiles
	)


func _can_drop(pos: Vector2i) -> bool:
	return pos in UnitMenu._get_drop_tiles(connected_unit)


static func _get_drop_tiles(unit: Unit) -> Array[Vector2i]:
	var traveler: Unit = unit.traveler
	var tiles: Array[Vector2i] = []
	for tile: Vector2i in Utilities.get_tiles(unit.get_path_last_pos(), 1, 1):
		var cost: float = MapController.map.get_terrain_cost(
			traveler.unit_class.get_movement_type(), tile
		)
		var movement: int = traveler.get_movement()
		if cost <= movement:
			tiles.append(tile)
	for adjacent_unit: Unit in MapController.map.get_units():
		var pos: Vector2i = adjacent_unit.position
		if pos in tiles:
			tiles.erase(pos)

	return tiles


func _display_adjacent_support_tiles() -> Node2D:
	var tiles: Array[Vector2i] = Utilities.get_tiles(connected_unit.get_path_last_pos(), 1, 1)
	return MapController.map.display_highlighted_tiles(tiles, connected_unit, Map.TileTypes.SUPPORT)


func _on_unit_death() -> void:
	close()


func _get_item_nodes() -> Array[MapMenuItem]:
	var output: Array[MapMenuItem] = []
	output.assign($Items.get_children())
	return output


func _wait() -> void:
	visible = false
	await connected_unit.move()
	connected_unit.wait()
	close()


func _attack(selected_unit: Unit) -> void:
	await connected_unit.move()
	await AttackController.combat(connected_unit, selected_unit)
	connected_unit.wait()
	close()


func _trade(selected_unit: Unit) -> void:
	var menu := TradeMenu.instantiate(connected_unit, selected_unit)
	MapController.get_ui().add_child(menu)
	CursorController.disable()
	visible = false
	if await menu.completed:
		await unactionable()
	else:
		connected_unit.display_movement_tiles()
	visible = true
	reset_size()


func _rescue(selected_unit: Unit) -> void:
	AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.BATTLE_SELECT)
	await connected_unit.move()
	await selected_unit.move(connected_unit.position)
	selected_unit.visible = false
	connected_unit.traveler = selected_unit
	_check_canto()
	close()


func _drop(dropped_tile: Vector2i) -> void:
	var traveler: Unit = connected_unit.traveler
	await connected_unit.move()
	traveler.visible = true
	traveler.position = connected_unit.position
	connected_unit.traveler = null
	await traveler.move(dropped_tile)
	_check_canto()
	close()


func _take(unit: Unit) -> void:
	await unactionable()
	var traveler: Unit = unit.traveler
	connected_unit.traveler = traveler
	unit.traveler = null
	traveler.visible = true
	await traveler.move(connected_unit.position)
	traveler.visible = false
	traveler.wait()
	visible = true
	CursorController.disable()
	CursorController.map_position = connected_unit.position
	update()


func _give(unit: Unit) -> void:
	await unactionable()
	var traveler: Unit = connected_unit.traveler
	unit.traveler = traveler
	connected_unit.traveler = null
	traveler.visible = true
	await traveler.move(unit.position)
	traveler.visible = false
	traveler.wait()
	visible = true
	update()
	CursorController.disable()


func _exchange(unit: Unit) -> void:
	await unactionable()
	var old_traveler: Unit = connected_unit.traveler
	var new_traveler: Unit = unit.traveler
	connected_unit.traveler = new_traveler
	unit.traveler = old_traveler
	old_traveler.visible = true
	new_traveler.visible = true
	old_traveler.move(unit.position)
	await new_traveler.move(connected_unit.position)
	old_traveler.visible = false
	new_traveler.visible = false
	old_traveler.wait()
	new_traveler.wait()
	visible = true
	CursorController.disable()
	CursorController.map_position = connected_unit.position
	update()


static func _base_instantiate(
	packed_scene: PackedScene,
	new_offset: Vector2,
	parent: MapMenu,
	unit_controller: SelectedUnitController = null,
	unit: Unit = null
) -> UnitMenu:
	var scene := super(packed_scene, new_offset, parent) as UnitMenu
	scene.caller = unit_controller
	scene.connected_unit = unit
	return scene


func _can_take(unit: Unit) -> bool:
	return connected_unit.is_friend(unit) and unit.traveler


func _can_give(unit: Unit) -> bool:
	return connected_unit.is_friend(unit) and not unit.traveler
