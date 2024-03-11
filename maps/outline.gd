extends Node2D


func _draw() -> void:
	for unit: Unit in MapController.get_units():
		unit.modulate = Color.WHITE
	var outlined_units: Dictionary = MapController.map.get_current_faction().outlined_units
	var map := get_parent().get_parent() as Map
	for outline_faction: Faction in map.all_factions:
		var current_outlined_units: Array[Unit] = []
		if outline_faction in outlined_units:
			current_outlined_units.assign(outlined_units[outline_faction])
		var all_current_coords: Array[Vector2i] = []
		var all_general_coords: Array[Vector2i] = []
		var unit_highlight: Color
		match outline_faction.color:
			Faction.colors.BLUE: unit_highlight = Color.BLUE
			Faction.colors.RED: unit_highlight = Color.RED
			Faction.colors.GREEN: unit_highlight = Color.GREEN
			Faction.colors.PURPLE: unit_highlight = Color.PURPLE
		for unit: Unit in current_outlined_units:
			if is_instance_valid(unit) and len(unit.get_all_attack_tiles()) > 0:
				unit.modulate = unit_highlight
				unit.modulate.s *= 0.5
				for coord: Vector2 in (unit.get_all_attack_tiles() + unit.get_raw_movement_tiles()):
					if not (coord in all_current_coords):
						all_current_coords.append(coord)
		var current_faction: Faction = map.get_current_faction()
		if current_faction.full_outline \
				and outline_faction != current_faction:
			for unit: Unit in MapController.get_units():
				var unit_faction: Faction = unit.get_faction()
				var unit_stance: Faction.diplo_stances = \
						current_faction.get_diplomacy_stance(unit_faction)
				if unit_stance == Faction.diplo_stances.ENEMY \
						and len(unit.get_all_attack_tiles()) > 0:
					for coord: Vector2i in (unit.get_all_attack_tiles() +
							unit.get_raw_movement_tiles()):
						if not (coord in all_general_coords):
							all_general_coords.append(coord)
		var tile_current: Color = unit_highlight
		var line_current: Color = tile_current
		line_current.v = .5
		for coords: Vector2 in all_current_coords:
			_create_outline_tile(tile_current, line_current, coords, all_current_coords)
		var tile_general: Color = tile_current
		tile_general.v = .5
		var line_general: Color = tile_general
		line_general.v *= .5
		for coords: Vector2 in all_general_coords:
			if not(coords in all_current_coords):
				_create_outline_tile(tile_general, line_general, coords, all_general_coords)


func _create_outline_tile(tile_color: Color, line_color: Color, coords: Vector2i,
		all_coords: Array[Vector2i]) -> void:
	tile_color.a = 0.5
	line_color.a = 0.5
	draw_rect(Rect2(coords, Vector2i(16, 16)), tile_color, true)
	for tile_offset: Vector2i in Utilities.adjacent_tiles:
		if coords + tile_offset in all_coords:
			pass
		else:
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
