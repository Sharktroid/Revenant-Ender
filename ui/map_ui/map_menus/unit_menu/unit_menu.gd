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


func receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		AudioPlayer.play_sound_effect(AudioPlayer.DESELECT)
		close(true)
	else:
		super(event)


func close(return_to_caller: bool = false) -> void:
	CursorController.enable()
	if not actionable:
		_check_canto()
	queue_free()
	if not (return_to_caller and actionable):
		caller.close()
	if _canto:
		CantoController.new(connected_unit)


func update() -> void:
	# Gets the items for the unit menu.
	var pos: Vector2i = connected_unit.get_path_last_pos()
	var movement: int = connected_unit.get_stat(Unit.stats.MOVEMENT)
	var movement_tiles: Array[Vector2i] = connected_unit.get_movement_tiles()
	var enabled_items: Dictionary = {
		Attack = false,
		Wait = false,
		Trade = false,
		Rescue = false,
		Take = false,
		Drop = false,
		Give = false,
		Swap = false,
		Items = false,
	}
	if CursorController.map_position in movement_tiles:
		enabled_items.Wait = (movement > 0 and pos in movement_tiles)
		enabled_items.Drop = connected_unit.traveler != null
		enabled_items.Items = connected_unit.items.size() > 0
		# Gets all adjacent units
		for unit: Unit in MapController.map.get_units():
			if unit != connected_unit and unit.visible == true:
				var cursor_pos: Vector2i = CursorController.map_position
				if Utilities.get_tile_distance(cursor_pos, unit.get_position()) == 0 \
						and not unit == connected_unit:
					# Units occupying the same tile
					if unit != connected_unit:
						enabled_items.Wait = false
				elif Utilities.get_tile_distance(cursor_pos, unit.get_position()) == 1:
					# Adjacent units
					if connected_unit.is_friend(unit):
						if connected_unit.items.size() > 0 and unit.items.size() > 0:
							enabled_items.Trade = true
						if unit.traveler:
							if connected_unit.traveler:
								enabled_items.Swap = true
							else:
								enabled_items.Take = true
						else:
							if connected_unit.traveler:
								enabled_items.Give = true
							elif connected_unit.can_rescue(unit):
								enabled_items.Rescue = true
				if _can_attack(unit):
					enabled_items.Attack = true
	else:
		if (CursorController.hovered_unit
				and _can_attack(CursorController.hovered_unit)):
			enabled_items.Attack = true
	for node: MapMenuItem in _get_item_nodes():
		node.visible = enabled_items[node.name]
	reset_size()


func select_item(item: MapMenuItem) -> void:
	match item.name:
		"Attack":
			var selector := AttackSelector.new(connected_unit, connected_unit.get_min_range(),
					connected_unit.get_max_range(), _can_attack, CursorController.icons.ATTACK)
			var tiles: Array[Vector2i] = connected_unit.get_current_attack_tiles(
					connected_unit.get_path_last_pos(), true)
			var tiles_node: Node2D = MapController.map.display_highlighted_tiles(tiles,
					connected_unit, Map.tileTypes.ATTACK)
			var attack: Callable = func(selected_unit: Unit) -> void:
				await connected_unit.move()
				await AttackController.combat(connected_unit, selected_unit)
				connected_unit.wait()
				close()
			_select_map(selector, tiles_node, attack)

		"Wait":
			_wait()

		"Trade":
			var selector := UnitSelector.new(connected_unit, 1, 1, connected_unit.is_friend)
			var trade: Callable = func(selected_unit: Unit) -> void:
				const MENU_NODE: PackedScene = \
						preload("res://ui/map_ui/map_menus/trade_menu/trade_menu.tscn")
				var menu := MENU_NODE.instantiate() as TradeMenu
				menu.left_unit = connected_unit
				menu.right_unit = selected_unit
				MapController.get_ui().add_child(menu)
				CursorController.disable()
				visible = false
				await menu.tree_exited
				await unactionable()
				visible = true
				reset_size()
				_current_item_index -= 1
			_select_map(selector, _display_adjacent_support_tiles(), trade)

		"Items":
			const MENU_PATH: String = "res://ui/map_ui/map_menus/item_menu/item_menu."
			const Menu = preload(MENU_PATH + "gd")
			const MENU_SCENE: PackedScene = preload(MENU_PATH + "tscn")
			var menu := MENU_SCENE.instantiate() as Menu
			menu.offset = offset
			menu.parent_menu = self
			menu.connected_unit = connected_unit
			MapController.get_ui().add_child(menu)
			visible = false

		"Rescue":
			var selector := UnitSelector.new(connected_unit, 1, 1, connected_unit.can_rescue)
			var rescue: Callable = func(selected_unit: Unit) -> void:
				AudioPlayer.play_sound_effect(AudioPlayer.BATTLE_SELECT)
				await connected_unit.move()
				await selected_unit.move(connected_unit.position)
				selected_unit.visible = false
				connected_unit.traveler = selected_unit
				_check_canto()
				close()
			_select_map(selector, _display_adjacent_support_tiles(), rescue)

		"Drop":
			var tiles_node: Node2D = (MapController.map as Map).display_tiles(_get_drop_tiles(),
					Map.tileTypes.SUPPORT)
			var drop: Callable = func(dropped_tile: Vector2i) -> void:
				var traveler: Unit = connected_unit.traveler
				await connected_unit.move()
				traveler.visible = true
				traveler.position = connected_unit.position
				connected_unit.traveler = null
				await traveler.move(dropped_tile)
				_check_canto()
				close()
			var tile_selector := TileSelector.new(connected_unit, 1, 1, _can_drop,
					CursorController.icons.NONE, AudioPlayer.BATTLE_SELECT)
			_select_map(tile_selector, tiles_node, drop)

		"Take":
			var can_take: Callable = func(unit: Unit) -> bool:
				return connected_unit.is_friend(unit) and unit.traveler
			var take: Callable = func(unit: Unit) -> void:
				await unactionable()
				var traveler: Unit = unit.traveler
				connected_unit.traveler = traveler
				unit.traveler = null
				traveler.visible = true
				await traveler.move(connected_unit.position)
				traveler.visible = false
				traveler.wait()
				visible = true
				update()
				CursorController.disable()
			_select_map(UnitSelector.new(connected_unit, 1, 1, can_take),
					_display_adjacent_support_tiles(), take)

		"Give":
			var can_give: Callable = func(unit: Unit) -> bool:
				return connected_unit.is_friend(unit) and not unit.traveler
			var give: Callable = func(unit: Unit) -> void:
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
			_select_map(UnitSelector.new(connected_unit, 1, 1, can_give),
					_display_adjacent_support_tiles(), give)

		"Swap":
			var can_swap: Callable = func(unit: Unit) -> bool:
				return connected_unit.is_friend(unit) and unit.traveler
			var swap: Callable = func(unit: Unit) -> void:
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
				update()
				CursorController.disable()
			_select_map(UnitSelector.new(connected_unit, 1, 1, can_swap),
					_display_adjacent_support_tiles(), swap)
	super(item)


func unactionable() -> void:
	actionable = false
	await connected_unit.move()


func _play_select_sound_effect(item: MapMenuItem) -> void:
	match item.name:
		"Wait": AudioPlayer.play_sound_effect(AudioPlayer.BATTLE_SELECT)
		_: AudioPlayer.play_sound_effect(AudioPlayer.MENU_SELECT)


func _check_canto() -> void:
	if connected_unit.has_skill_attribute(Skill.allAttributes.CANTO):
		_canto = true
	else:
		connected_unit.wait()


func _select_map(selector: Selector, tiles_node: Node2D, selected: Callable,
		canceled: Callable = func() -> void: pass) -> void:
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
		var selection: Vector2i = await (selector as TileSelector).selected
		if selection == null:
			canceled.call()
			visible = true
		else:
			selected.call(selection)
	tiles_node.queue_free()


func _can_attack(unit: Unit) -> bool:
	var pos: Vector2i = connected_unit.get_path_last_pos()
	var current_tiles: Array[Vector2i] = connected_unit.get_current_attack_tiles(pos, true)
	var faction: Faction = unit.faction
	var diplo_stance := connected_unit.faction.get_diplomacy_stance(faction)
	if diplo_stance == Faction.diplomacyStances.ENEMY and Vector2i(unit.position) in current_tiles:
		return true
	return false


func _can_drop(pos: Vector2i) -> bool:
	return pos in _get_drop_tiles()


func _get_drop_tiles() -> Array[Vector2i]:
	var traveler: Unit = connected_unit.traveler
	var tiles: Array[Vector2i] = []
	for tile: Vector2i in \
			connected_unit.get_adjacent_tiles(connected_unit.get_path_last_pos(), 1, 1):
		var cost: float = MapController.map.get_terrain_cost(traveler.unit_class.movement_type, tile)
		var movement: int = traveler.get_stat(Unit.stats.MOVEMENT)
		if cost <= movement:
			tiles.append(tile)
	for unit: Unit in MapController.map.get_units():
		var pos: Vector2i = unit.position
		if pos in tiles:
			tiles.erase(pos)

	return tiles


func _display_adjacent_support_tiles() -> Node2D:
	var tiles: Array[Vector2i] = connected_unit.get_adjacent_tiles(
			connected_unit.get_path_last_pos(), 1, 1)
	return MapController.map.display_highlighted_tiles(tiles, connected_unit,
			Map.tileTypes.SUPPORT)


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
