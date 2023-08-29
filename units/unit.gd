@tool
class_name Unit
extends Sprite2D

signal arrived # When unit arrives at its target
signal cursor_exited

enum statuses {ATTACK}
enum animations {IDLE, MOVING_DOWN, MOVING_UP, MOVING_LEFT, MOVING_RIGHT}
enum stats {
	HITPOINTS, STRENGTH, PIERCE, MAGIC, SKILL, SPEED, LUCK, DEFENSE, DURABILITY,
	RESISTANCE, MOVEMENT, CONSTITUTION, AUTHORITY
}

## Unit's faction. Should be in the map's Faction stack.
@export var faction_id: int
@export var variant: String # Visual variant.
@export var items: Array[Item]
@export var base_level: int = 1
@export var skills: Array[Skill] = [Follow_Up.new()]
@export var unit_class: UnitClass
@export var portrait: Texture2D

var personal_stat_caps: Dictionary
var personal_end_stats: Dictionary
var personal_base_stats: Dictionary
var current_level: int
var current_movement: int
var all_attack_tiles: Array[Vector2i] # Tiles displayed as attack tiles.
var raw_movement_tiles: Array[Vector2i] # All movement tiles without organization.
var dead: bool = false
var outline_highlight: bool = false
var is_ghost: bool = false # Whether the unit is used for the cursor.
var selected: bool = false # Whether the unit is selected.
var selectable: bool = true # Whether the unit can be selected.
var waiting: bool = false
var sprite_animated: bool = true:
	set(value):
		sprite_animated = value
		if sprite_animated:
			$AnimationPlayer.play($AnimationPlayer.current_animation)
		else:
			$AnimationPlayer.pause()
var weapon_levels: Dictionary
var traveler: Unit

var _path: Array[Vector2i] # Path the unit will follow when moving.
var _current_statuses: Array[statuses]
var _target # Destination of the unit during movement.
var _current_health: float: get = get_current_health, set = set_current_health
var _movement_speed: float = 8 # Speed unit moves across the map.
static var _all_units: Dictionary # Lists all unit classes.
# Dictionaries that convert faction/variant into animation modifier.
var _movement_tiles: Dictionary # Movement tiles. Split by cost left.
var _movement_tiles_node: Node2D
var _attack_tile_node: Node2D
var _current_attack_tiles_node: Node2D
# Resources to be loaded.
var _movement_arrows: Resource = load("uid://8h4ym31xu44m")
var _stat_boosts: Dictionary
var _default_palette: Array[Array] = [[Vector3(), Vector3()]]
var _wait_palette: Array[Array] = [
	[Vector3(24, 240, 248), Vector3(184, 184, 184)],
	[Vector3(144, 184, 232), Vector3(120, 120, 120)],
	[Vector3(248, 248, 64), Vector3(200, 200, 200)],
	[Vector3(232, 16, 24), Vector3(112, 112, 112)],
	[Vector3(56, 56, 144), Vector3(72, 72, 72)],
	[Vector3(248, 248, 248), Vector3(208, 208, 208)],
	[Vector3(56, 80, 224), Vector3(88, 88, 88)],
	[Vector3(112, 96, 96), Vector3(80, 80, 80)],
	[Vector3(248, 248, 208), Vector3(200, 200, 200)],
	[Vector3(88, 72, 120), Vector3(64, 64, 64)],
	[Vector3(216, 232, 240), Vector3(184, 184, 184)],
	[Vector3(40, 160, 248), Vector3(152, 152, 152)],
	[Vector3(176, 144, 88), Vector3(128, 128, 128)],
]
var _red_palette: Array[Array] = [
	[Vector3(56, 56, 144), Vector3(96, 40, 32)],
	[Vector3(56, 80, 224), Vector3(168, 48, 40)],
	[Vector3(40, 160, 248), Vector3(224, 16, 16)],
	[Vector3(24, 240, 248), Vector3(248, 80, 72)],
	[Vector3(232, 16, 24), Vector3(56, 208, 48)],
	[Vector3(88, 72, 120), Vector3(104, 72, 96)],
	[Vector3(216, 232, 240), Vector3(224, 224, 224)],
	[Vector3(144, 184, 232), Vector3(192, 168, 184)],
]
var _green_palette: Array[Array] = [
	[Vector3(56, 56, 144), Vector3(32, 80, 16)],
	[Vector3(56, 80, 224), Vector3(8, 144, 0)],
	[Vector3(40, 160, 248), Vector3(24, 208, 16)],
	[Vector3(24, 240, 248), Vector3(80, 248, 56)],
	[Vector3(232, 16, 24), Vector3(0, 120, 200)],
	[Vector3(88, 72, 120), Vector3(56, 80, 56)],
	[Vector3(144, 184, 232), Vector3(152, 200, 158)],
	[Vector3(216, 232, 240), Vector3(216, 248, 184)],
	[Vector3(112, 96, 96), Vector3(88, 88, 80)],
	[Vector3(176, 144, 88), Vector3(160, 136, 64)],
	[Vector3(248, 248, 208), Vector3(248, 248, 192)],
	[Vector3(248, 248, 64), Vector3(224, 248, 40)],
]
var _purple_palette: Array[Array] = [
	[Vector3(56, 56, 144), Vector3(88, 32, 96)],
	[Vector3(56, 80, 224), Vector3(128, 48, 144)],
	[Vector3(40, 160, 248), Vector3(184, 72, 224)],
	[Vector3(24, 240, 248), Vector3(208, 96, 248)],
	[Vector3(232, 16, 24), Vector3(56, 208, 48)],
	[Vector3(88, 72, 120), Vector3(88, 64, 104)],
	[Vector3(144, 184, 232), Vector3(168, 168, 232)],
	[Vector3(64, 56, 56), Vector3(72, 40, 64)],
]
var _arrows_container: CanvasGroup


func _ready() -> void:
	for weapon_type in unit_class.weapon_levels.keys():
		if weapon_type not in weapon_levels.keys():
			weapon_levels[weapon_type] = unit_class.weapon_levels[weapon_type]
	texture = (unit_class as UnitClass).map_sprite
	material = material.duplicate()
	current_level = base_level
	current_movement = get_stat(stats.MOVEMENT)
	_update_palette()
	set_current_health(get_stat(stats.HITPOINTS))
	add_to_group("units")

	var animation_player: AnimationPlayer = ($AnimationPlayer as AnimationPlayer)
	if animation_player.current_animation == '':
		animation_player.play("idle")
	GenFunc.sync_animation(animation_player)

	# Setting up "_all_units"
	if not _all_units:
		var dir = DirAccess.open("res://units/")
		if dir:
			dir.list_dir_begin()
			var file_name: String = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir() and "gd" == file_name.get_slice(".", -1):
					var file = load("res://units/%s" % file_name).new()
					var scene_name: String = "res://units/%s.tscn" % file_name.get_slice('.', 0)
					_all_units[file.unit_class] = load(scene_name)
				file_name = dir.get_next()
		else:
			push_error('An error occurred when trying to access the path "res://units/".')
		_all_units.erase('')


func _physics_process(_delta: float) -> void:
	# Moving the unit.
	if _target != null:
		get_node("Area2D").monitoring = false
		position = position.move_toward(_target, _movement_speed)
		if Vector2i(position) == _target:
			if len(_path) == 0:
				_target = null
				get_node("Area2D").monitoring = true
				emit_signal("arrived")

			else:
				_target = _path.pop_at(0)
				match floori(position.angle_to_point(_target) / PI * 2) + 1:
					0: set_animation(animations.MOVING_DOWN)
					1: set_animation(animations.MOVING_RIGHT)
					2: set_animation(animations.MOVING_UP)
					3: set_animation(animations.MOVING_LEFT)
					_: set_animation(animations.IDLE)


func _process(_delta: float):
	_render_status()
	if Engine.get_process_frames() % 60 == 0:
		GenFunc.sync_animation($AnimationPlayer)
#	if outline_highlight:
#		modulate = Color.RED
#	else:
#		modulate = Color.WHITE


func has_status(status: int) -> bool:
	return status in _current_statuses


func add_status(status: int) -> void:
	_current_statuses.append(status)


func remove_status(status: int) -> void:
	_current_statuses.erase(status)


func get_class_name() -> String:
	return unit_class.name


func get_current_weapon() -> Weapon:
	for item in items:
		if item is Weapon:
			if can_use_weapon(item):
				return item
	return null


func get_attack() -> int:
	if get_current_weapon():
		var current_attack: int
		match get_current_weapon().get_damage_type():
			Weapon.damage_types.PHYSICAL: current_attack = get_stat(stats.STRENGTH)
			Weapon.damage_types.RANGED: current_attack = get_stat(stats.PIERCE)
			Weapon.damage_types.MAGIC: current_attack = get_stat(stats.MAGIC)
		return get_current_weapon().might + current_attack
	else:
		return 0


func get_damage(defender: Unit) -> float:
	return max(0, get_attack() - defender.get_current_defence(items[0].get_damage_type()))


## Sets units current health.
func set_current_health(health: float) -> void:
	_current_health = clampf(health, 0, get_stat(stats.HITPOINTS))
	if not Engine.is_editor_hint():
		$"Health Bar".update()


func get_current_health() -> float:
	return _current_health


## Increases "current_health" by "added_health".
func add_current_health(added_health: float, does_die: bool = true) -> void:
	set_current_health(get_current_health() + added_health)
	if get_current_health() <= 0 and does_die:
		die()


func set_animation(animation: animations) -> void:
	var animation_player: AnimationPlayer = ($AnimationPlayer as AnimationPlayer)
	animation_player.play("RESET")
	animation_player.advance(0)
	match animation:
		animations.IDLE: animation_player.play("idle")
		animations.MOVING_LEFT: animation_player.play("moving_left")
		animations.MOVING_RIGHT: animation_player.play("moving_right")
		animations.MOVING_UP: animation_player.play("moving_up")
		animations.MOVING_DOWN: animation_player.play("moving_down")
	if sprite_animated:
		GenFunc.sync_animation(animation_player)
	else:
		animation_player.advance(0)
		animation_player.pause()


func get_stat_boost(stat: stats) -> int:
	return _stat_boosts.get(stat, 0)


func get_stat(stat: stats, level: int = current_level) -> int:
	var base_stat: int = unit_class.base_stats.get(stat, 0) + personal_base_stats.get(stat, 0)
	var end_stat: int = unit_class.end_stats.get(stat, 0) + personal_end_stats.get(stat, 0)
	var weight: float = inverse_lerp(1, unit_class.max_level, level)
	var leveled_stat: int = roundi(lerpf(base_stat, end_stat, weight))
	return clampi(leveled_stat + get_stat_boost(stat), 0, get_stat_cap(stat))


func get_stat_cap(stat: stats) -> int:
	return unit_class.stat_caps.get(stat, 0) + personal_stat_caps.get(stat, 0)


func get_attack_speed() -> int:
	var weight: int = 0
	if get_current_weapon():
		weight = get_current_weapon().weight
	return get_stat(stats.SPEED) - max(weight - get_stat(stats.CONSTITUTION), 0)


func get_current_defence(attacker_weapon_type: Weapon.damage_types) -> int:
	match attacker_weapon_type:
		Weapon.damage_types.RANGED: return get_stat(stats.DURABILITY)
		Weapon.damage_types.MAGIC: return get_stat(stats.RESISTANCE)
		Weapon.damage_types.PHYSICAL: return get_stat(stats.DEFENSE)
		_:
			push_error("Damage Type %s Invalid" % attacker_weapon_type)
			return 0


func get_max_level() -> int:
	return unit_class.max_level


func get_area() -> Area2D:
	return $Area2D


func get_portrait() -> Texture2D:
	if portrait:
		return portrait
	else:
		return unit_class.default_portrait


func get_portrait_offset() -> Vector2i:
	if portrait:
		return Vector2i(-8, 0)
	else:
		return Vector2i()


func get_aid() -> int:
	var aid_mod: int = unit_class.aid_modifier
	if aid_mod <= 0:
		return get_stat(stats.CONSTITUTION) + aid_mod
	else:
		return aid_mod - get_stat(stats.CONSTITUTION)


func get_weight() -> int:
	return get_stat(stats.CONSTITUTION) + unit_class.weight_modifier


func has_attribute(attrib: Skill.all_attributes) -> bool:
	for skill in skills:
		if attrib in (skill as Skill).attributes:
			return true
	return false


func can_use_weapon(weapon: Weapon) -> bool:
	return weapon.level <= weapon_levels.get(weapon.type, 0)


func can_rescue(unit: Unit) -> bool:
	return unit.get_weight() < get_aid() and is_friend(unit) and not traveler


## Causes unit to wait.
func wait() -> void:
	if GenVars.get_debug_constant("unit_wait"):
		current_movement = 0
		selectable = false
		waiting = true
	GenVars.map.unit_wait(self)
	_update_palette()


func die() -> void:
	dead = true
	$Area2D.queue_free()
	await $Area2D.area_exited
	var fade = FadeOut.new(20.0/60)
	add_child.call_deferred(fade)
	await fade.complete
	queue_free()


## Deselects unit.
func deselect() -> void:
	set_animation(animations.IDLE)
	selected = false
	remove_path()
	if GenVars.cursor.get_hovered_unit() == self:
		refresh_tiles()
	else:
		hide_movement_tiles()


## Un-waits unit.
func awaken() -> void:
	current_movement = get_stat(stats.MOVEMENT)
	selectable = true
	waiting = false
	_update_palette()


## Displays the unit's movement tiles.
func display_movement_tiles() -> void:
	var display: Callable = GenVars.map.display_tiles
	_movement_tiles_node = display.call(get_raw_movement_tiles(), Map.tile_types.MOVEMENT, 1)
	_attack_tile_node = display.call(get_all_attack_tiles(), Map.tile_types.ATTACK, 1)
	if not selected:
		_movement_tiles_node.modulate.a = 0.5
		_attack_tile_node.modulate.a = 0.5


## Hides the unit's movement tiles.
func hide_movement_tiles() -> void:
	if is_instance_valid(_movement_tiles_node):
		_movement_tiles_node.queue_free()
		_attack_tile_node.queue_free()


func get_adjacent_tiles(pos: Vector2i, min_range: int, max_range: int) -> Array[Vector2i]:
	var adjacent_tiles: Array[Vector2i] = []
	for y in range(-max_range, max_range + 1):
		var v: Array[Vector2i] = []
		for x in range(-max_range, max_range + 1):
			var distance: int = floori(GenFunc.get_tile_distance(Vector2i(), Vector2i(x, y) * 16))
			if distance in range(min_range, max_range + 1):
				v.append(Vector2i(pos) + Vector2i(x * 16, y * 16))
		adjacent_tiles.append_array(v)
	return adjacent_tiles


func get_current_attack_tiles(pos: Vector2i) -> Array[Vector2i]:
	return get_adjacent_tiles(pos, get_current_weapon().min_range, get_current_weapon().max_range)


## Shows off the tiles the unit can attack from its current position.
func display_current_attack_tiles(pos: Vector2i) -> void:
	var current_tiles: Array[Vector2i] = get_current_attack_tiles(pos)
	var display_tiles: Callable = GenVars.map.display_highlighted_tiles
	var attack_type: Map.tile_types = Map.tile_types.ATTACK
	_current_attack_tiles_node = display_tiles.call(current_tiles, self, attack_type)


## Hides current attack tiles.
func hide_current_attack_tiles() -> void:
	_current_attack_tiles_node.queue_free()


## Refreshes tiles
func refresh_tiles() -> void:
	if is_instance_valid(_movement_tiles_node):
		match selected:
			true:
				_movement_tiles_node.modulate.a = 1
				_attack_tile_node.modulate.a = 1
			false:
				_movement_tiles_node.modulate.a = .5
				_attack_tile_node.modulate.a = .5


## Adds skill to this unit's skills.
func add_skill(skill: Skill) -> void:
	skills.append(skill)


## Moves unit to "move_target"
func move(move_target: Vector2i = get_unit_path()[-1]) -> void:
	hide_movement_tiles()
	if not(move_target in get_unit_path()):
		update_path(move_target)
	if move_target in get_unit_path():
		_target = _path.pop_at(0)
	selected = false
	reset_tiles()


func reset_tiles() -> void:
	_movement_tiles = {}
	all_attack_tiles = []
	raw_movement_tiles = []
#	_true_attack_tiles


func get_unit_path() -> Array[Vector2i]:
	if len(_path) == 0:
		return [position]
	else:
		return _path


func get_faction() -> Faction:
	if len(GenVars.map.faction_stack) > 0:
		return (GenVars.map as Map).faction_stack[faction_id]
	else:
		return null


## Changes unit's faction.
func set_faction(new_faction: Faction) -> void:
	faction_id = (GenVars.map as Map).faction_stack.find(new_faction)


## Gets the path of the unit.
func update_path(destination: Vector2i, num: int = current_movement) -> void:
	var moved = position
	var moved_tiles: Array[Vector2i] = [position]
	if len(_path) == 0:
		_path.append(Vector2i(position))
	# Sets destination to an adjacent tile to a unit if a unit is hovered and over an attack tile.
	if not destination in raw_movement_tiles \
			and destination in all_attack_tiles \
			and GenFunc.get_tile_distance(get_unit_path()[-1], destination) > 1:
		for unit in get_tree().get_nodes_in_group("units"):
			var unit_origin: Vector2i = unit.position
			if unit_origin in all_attack_tiles and unit_origin == destination:
				var adjacent_movement_tiles: Array[Vector2i] = []
				for tile_offset in GenVars.adjacent_tiles:
					if Vector2i(unit.position) + tile_offset in raw_movement_tiles:
						adjacent_movement_tiles.append(Vector2i(unit.position) + tile_offset)
				if len(adjacent_movement_tiles) > 0:
					adjacent_movement_tiles.shuffle()
					destination = (adjacent_movement_tiles)[0]
					break

	if destination in raw_movement_tiles:
		# Gets the path
		var total_cost = 0
		for tile in _path:
			if tile != Vector2i(position):
				total_cost += GenVars.map.get_terrain_cost(self, tile)
		if destination in _path:
			_path = _path.slice(0, _path.find(destination) + 1)
		else:
			var displaced_tile = destination - get_unit_path()[-1]
			if total_cost <= current_movement and (displaced_tile in GenVars.adjacent_tiles):
				_path.append(destination)
			else:
				var rmt = raw_movement_tiles # Abbreviation to make line fit.
				var new_path = _get_path_subfunc(num, moved, rmt, moved_tiles, destination)
				if new_path is Array[Vector2i]:
					_path = new_path


## Displays the unit's path
func show_path() -> void:
	if is_instance_valid(_arrows_container):
		_arrows_container.queue_free()
	_arrows_container = CanvasGroup.new()
	if len(get_unit_path()) > 1:
		for i in get_unit_path():
			var tile: Sprite2D = _movement_arrows.instantiate()
			var prev
			var next
			if get_unit_path().find(i) == 0:
				prev = i - Vector2i(position)
			else:
				prev = i - get_unit_path()[get_unit_path().find(i) - 1]
			if i != get_unit_path()[-1]:
				next = i - get_unit_path()[get_unit_path().find(i) + 1]
			if get_unit_path()[0] == i:
				match next:
					Vector2i(-16, 0): tile.frame = 0
					Vector2i(16, 0): tile.frame = 8
					Vector2i(0, 16): tile.frame = 7
					Vector2i(0, -16): tile.frame = 1
			elif i == get_unit_path()[-1]:
				match prev:
						Vector2i(16, 0): tile.frame = 4
						Vector2i(-16, 0): tile.frame = 12
						Vector2i(0, 16): tile.frame = 5
						Vector2i(0, -16): tile.frame = 11
			else:
				if Vector2i(16, 0) in [prev, next] and Vector2i(-16, 0) in [prev, next]:
					tile.frame = 13
				elif Vector2i(16, 0) in [prev, next] and Vector2i(0, 16) in [prev, next]:
					tile.frame = 10
				elif Vector2i(16, 0) in [prev, next] and Vector2i(0, -16) in [prev, next]:
					tile.frame = 3
				elif Vector2i(-16, 0) in [prev, next] and Vector2i(0, -16) in [prev, next]:
					tile.frame = 2
				elif Vector2i(-16, 0) in [prev, next] and Vector2i(0, 16) in [prev, next]:
					tile.frame = 9
				elif Vector2i(0, 16) in [prev, next] and Vector2i(0, -16) in [prev, next]:
					tile.frame = 6
			tile.position = i as Vector2
			_arrows_container.add_child(tile)
		GenVars.map.add_child(_arrows_container)


func get_raw_movement_tiles() -> Array[Vector2i]:
	if len(raw_movement_tiles) < 1:
		_get_movement_tiles()
	return raw_movement_tiles


func get_all_attack_tiles() -> Array[Vector2i]:
	if len(all_attack_tiles) < 1:
		_create_all_attack_tiles()
	return all_attack_tiles


func get_new_map_attack() -> MapAttack:
	# Returns a new instance of the class's map attack animation
	return load("res://map_attack.tscn").instantiate()


func remove_path() -> void:
	# Removes the unit's path
	if is_instance_valid(_arrows_container):
		_arrows_container.queue_free()


func is_friend(other_unit: Unit):
	return get_faction().is_friend(other_unit.get_faction())


func _update_palette() -> void:
	if get_faction():
		_set_palette(get_faction().color)


func _render_status() -> void:
	pass


func _get_movement_tiles() -> void:
	# Gets the movement tiles of the unit
	var h = []
	var tiles_first_pass = {}
	var tiles_second_pass = {}
	var start: Vector2i = (position)
	if position == ((position/16).floor() * 16):
		# Gets the initial grid
		for y in range(-current_movement, current_movement + 1):
			var v = []
			for x in range(-(current_movement - absi(y)) , (current_movement - absi(y)) + 1):
				v.append(start + Vector2i(x * 16, y * 16))
			h.append_array(v)
		# Seperates by remaining movement
		for x in h:
			var boundary: Vector2i = GenVars.map.get_size() - Vector2i(16, 16)
			if x == x.clamp(Vector2i(), boundary):
				var val = floori(current_movement - (absf(x.x - start.x) + absf(x.y - start.y))/16)
				if not(val in tiles_first_pass):
					tiles_first_pass[val] = []
				tiles_first_pass[val].append(x)
		# Reduces tile value by terrain cost.
		for k in tiles_first_pass.keys():
			var v = tiles_first_pass[k]
			for i in v:
				var val = k
				if i != start:
					var cost = (GenVars.map.get_terrain_cost(self, i)) - 1
					val -= cost
				if not(val in tiles_second_pass.keys()):
					tiles_second_pass[val] = []
				tiles_second_pass[val].append(i)
		var max_val = tiles_second_pass.keys().max()
		# Calculates each tile if they have the right movement value.
		for k in range(max_val, -1, -1):
			if k in tiles_second_pass.keys():
				var v = tiles_second_pass[k]
				for tile in v:
					var cost = (GenVars.map.get_terrain_cost(self, tile))
					var val = k
					var valid = false
					if tile != start:
						if val + cost in _movement_tiles.keys():
							for c in _movement_tiles[val + cost]:
								if (c - tile) in [Vector2i(-16, 0), Vector2i(16, 0),
										Vector2i(0, -16), Vector2i(0, 16)]:
									valid = true
									break
						if valid == false:
							val -= 1
					if val == k:
						if not(val in _movement_tiles.keys()):
							_movement_tiles[val] = []
						_movement_tiles[val].append(tile)
					else:
						if not(val in tiles_second_pass.keys()):
							tiles_second_pass[val] = []
						tiles_second_pass[val].append(tile)
		raw_movement_tiles = []
		for v in _movement_tiles.values():
			raw_movement_tiles.append_array(v)


func _create_all_attack_tiles() -> void:
	# Gets all the attack tiles
	if get_current_weapon():
		for tile in get_raw_movement_tiles():
			var min_range: int = get_current_weapon().min_range
			var max_range: int = get_current_weapon().max_range
			for y in range(-max_range, max_range + 1):
				for x in range(-max_range, max_range + 1):
					var tile_min: Vector2i = tile + Vector2i(x * 16, y * 16)
					var attack_tile: Vector2i = GenVars.map.get_size() - Vector2i(16, 16)
					attack_tile = tile_min.clamp(Vector2i(0, 0), attack_tile)
					if not(attack_tile in all_attack_tiles + raw_movement_tiles):
						var distance: int = floori(GenFunc.get_tile_distance(tile, attack_tile))
						if distance in range(min_range, max_range + 1):
							all_attack_tiles.append(attack_tile)


func _set_palette(color: Faction.colors) -> void:
	var palette: Array[Array]
	match waiting:
		true: palette = _wait_palette
		false:
			match color:
				Faction.colors.RED: palette = _red_palette
				Faction.colors.GREEN : palette = _green_palette
				Faction.colors.BLUE: palette = _default_palette
				Faction.colors.PURPLE: palette = _purple_palette
				var invalid:
					palette = _default_palette
					push_error("Color %s does not have a palette." % invalid)
	var old_colors: Array[Vector3] = []
	var new_colors: Array[Vector3] = []
	for color_set in palette:
		old_colors.append(color_set[0])
		new_colors.append(color_set[1])
	(material as ShaderMaterial).set_shader_parameter("old_colors", old_colors)
	(material as ShaderMaterial).set_shader_parameter("new_colors", new_colors)


func _get_path_subfunc(num: int, moved: Vector2i, all_tiles: Array[Vector2i],
		moved_tiles: Array[Vector2i], destination: Vector2i):
	# Recursive function used for getting the path. Do not use outside of "get_path".
	if num > 0:
		# Sets the order the path is checked in.
		# Large amounts of lag can occur if the order starts with a far tile.
		# Some RNG is used for aethetics; can possibly lag at extreme values.
		var order = []
		var order_ready: bool = false
		for axis in 2:
			# Goes straight first when the destination is straight ahead
			if is_zero_approx(destination[axis] - moved[axis]):
				var other_axis: int = (axis + 1) % 2
				var mid = Vector2i()
				mid[axis] = 16
				order = [mid, -mid]
				order.shuffle()
				var first := Vector2i()
				first[other_axis] = 16
				if destination[other_axis] - moved[other_axis] < 0:
					first = -first
				order = [first] + order + [-first]
				order_ready = true
				break
		if not order_ready:
			# Checks both directions when destination is not straight in one axis.
			var lead_x := Vector2i(16, 0)
			var lead_y := Vector2i(0, 16)
			if destination.x - moved.x < 0:
				lead_x = -lead_x
			if destination.y - moved.y < 0:
				lead_y = -lead_y
			order = [lead_x, lead_y]
			order.shuffle()
			var end: Array[Vector2i] = [-lead_x, -lead_y]
			end.shuffle()
			order.append_array(end)
		# Checks each direction.
		for i in order:
			if moved + i in all_tiles and not(moved + i in moved_tiles):
				var temp_moved_tiles = moved_tiles.duplicate()
				var temp_moved = moved
				temp_moved += i
				temp_moved_tiles.append(temp_moved)
				if temp_moved == destination:
					moved_tiles = temp_moved_tiles
					return moved_tiles
				var new_num: int = num - GenVars.map.get_terrain_cost(self, temp_moved)
				var tmt = temp_moved_tiles # Abbreviation
				var value = _get_path_subfunc(new_num, temp_moved, all_tiles, tmt, destination)
				if value != null:
					return value


func _on_area2d_area_entered(area: Area2D):
	# When cursor enters unit's area
	if area == (GenVars.cursor as Cursor).get_area():
		var selecting: bool = GenVars.map_controller.selecting
		var can_be_selected: bool = true
		if is_instance_valid(GenVars.cursor.get_hovered_unit()):
			can_be_selected = not GenVars.cursor.get_hovered_unit().selected or selecting
		if can_be_selected:
			if not(selected or selecting or waiting):
				display_movement_tiles()
		GenVars.cursor.set_hovered_unit(self)


func _on_area2d_area_exited(area: Area2D):
	# When cursor exits unit's area
	if area == (GenVars.cursor as Cursor).get_area() and not selected:
		hide_movement_tiles()
		emit_signal("cursor_exited")


func _on_create_menu_select_item(item: String) -> void:
	if item in _all_units.keys():
		var new_unit: Unit = _all_units[item].instantiate()
		new_unit.position = position
		new_unit.faction_id = faction_id
		get_parent().add_child(new_unit)
	GenVars.map_controller.get_node("UILayer/Unit Menu").close()


func _on_create_menu_closed() -> void:
	GenVars.map_controller.get_node("UILayer/Unit Menu").set_active(true)
