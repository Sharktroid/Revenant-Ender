extends Node2D


func _draw() -> void:
	for unit: Unit in MapController.map.get_units():
		unit.modulate = Color.WHITE
	var outlined_units: Dictionary[Faction, Array] = MapController.map.get_current_faction().outlined_units
	for outline_faction: Faction in MapController.map.all_factions:
		var current_outlined_units: Array[Unit] = []
		if outlined_units.has(outline_faction):
			current_outlined_units.assign(outlined_units[outline_faction] as Array)
		var unit_highlight: Color = _get_unit_highlight(outline_faction.color)
		var all_current_coords: Set = _get_all_current_coords(
			current_outlined_units, unit_highlight
		)
		var all_general_coords: Set = _get_all_general_coords(outline_faction)
		var tile_current: Color = unit_highlight
		var line_current: Color = tile_current
		line_current.v = .5
		for coords: Vector2 in all_current_coords:
			_create_outline_tile(tile_current, line_current, coords, all_current_coords)
		var tile_general: Color = tile_current
		tile_general.v = .5
		var line_general: Color = tile_general
		line_general.v *= .5
		for coords: Vector2i in all_general_coords.filter(
			_is_within_coords.bind(all_current_coords)
		):
			_create_outline_tile(tile_general, line_general, coords, all_general_coords)


func _create_outline_tile(
	tile_color: Color, line_color: Color, coords: Vector2i, all_coords: Set
) -> void:
	tile_color.a = 0.5
	line_color.a = 0.5
	draw_rect(Rect2(coords, Vector2i(16, 16)), tile_color, true)

	for tile_offset: Vector2i in Utilities.get_tiles(Vector2i.ZERO, 1).filter(
		func(tile_offset: Vector2i) -> bool: return not all_coords.has(coords + tile_offset)
	):
		var offset: Vector2 = coords
		match tile_offset:
			Vector2i(-16, 0):
				draw_line(Vector2(0.5, 0) + offset, Vector2(0.5, 16) + offset, line_color, 1)
			Vector2i(0, -16):
				draw_line(Vector2(0, 0.5) + offset, Vector2(16, 0.5) + offset, line_color, 1)
			Vector2i(16, 0):
				draw_line(Vector2(15.5, 0) + offset, Vector2(15.5, 16) + offset, line_color, 1)
			Vector2i(0, 16):
				draw_line(Vector2(0, 15.5) + offset, Vector2(16, 15.5) + offset, line_color, 1)


func _is_within_coords(coord: Vector2i, coords: Set) -> bool:
	return not coords.has(coord)


func _get_unit_highlight(color: Faction.Colors) -> Color:
	match color:
		Faction.Colors.RED:
			return Color.RED
		Faction.Colors.GREEN:
			return Color.GREEN
		Faction.Colors.PURPLE:
			return Color.PURPLE
		_:
			return Color.BLUE


func _get_all_current_coords(
	current_outlined_units: Array[Unit], unit_highlight: Color
) -> Set:
	var can_unit_attack: Callable = func(unit: Unit) -> bool:
		return is_instance_valid(unit) and not unit.get_all_attack_tiles().is_empty()
	var all_current_coords := Set.new()
	for unit: Unit in current_outlined_units.filter(can_unit_attack):
		unit.modulate = unit_highlight
		unit.modulate.s *= 0.5
		all_current_coords.append_array(
			unit.get_all_attack_tiles().filter(_is_within_coords.bind(all_current_coords)).to_array()
		)
	return all_current_coords


func _get_all_general_coords(outline_faction: Faction) -> Set:
	var can_enemy_attack: Callable = func(unit: Unit) -> bool:
		const ENEMY: Faction.DiplomacyStances = Faction.DiplomacyStances.ENEMY
		return (
			MapController.map.get_current_faction().get_diplomacy_stance(unit.faction) == ENEMY
			and not unit.get_all_attack_tiles().is_empty()
		)

	var all_general_coords := Set.new()
	var current_faction: Faction = MapController.map.get_current_faction()
	if current_faction.full_outline and outline_faction != current_faction:
		for unit: Unit in MapController.map.get_units().filter(can_enemy_attack):
			all_general_coords.append_array(
				unit.get_all_attack_tiles().filter(_is_within_coords.bind(all_general_coords)).to_array()
			)
	return all_general_coords
