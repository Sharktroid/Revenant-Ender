@tool
class_name Unit
extends Sprite2D

signal cursor_exited

enum Statuses { ATTACK }
enum Animations { IDLE, MOVING_DOWN, MOVING_UP, MOVING_LEFT, MOVING_RIGHT }
enum Stats {
	HIT_POINTS,
	STRENGTH,
	PIERCE,
	MAGIC,
	SKILL,
	SPEED,
	LUCK,
	DEFENSE,
	ARMOR,
	RESISTANCE,
	MOVEMENT,
	CONSTITUTION,
}

## Duration of fade-away upon death
const FADE_AWAY_DURATION: float = 20.0 / 60
## The amount that the stat is multiplied by with max PVs
const PERSONAL_VALUE_MULTIPLIER: float = 0.15
## The amount that the stat is multiplied by with max EVs
const EFFORT_VALUE_MULTIPLIER: float = 0.15
## The maximum value that a PV can be
const PERSONAL_VALUE_LIMIT: int = 15
## The maximum value that an EV can be
const INDIVIDUAL_EFFORT_VALUE_LIMIT: int = 250
## The maximum amount of PVs a unit can have
const TOTAL_EFFORT_VALUE_LIMIT: float = INDIVIDUAL_EFFORT_VALUE_LIMIT * 4
## The experience required to go from level 1 to level 2
const BASE_EXP: int = 100
## The multiplier for the extra amount of experience to go from one level to the next
## compared to the previous level
const EXP_MULTIPLIER: float = 2
## The amount of experience for killing an enemy in one round of combat
const ONE_ROUND_EXP_BASE: float = float(BASE_EXP) / 3
## The amount of combat experience reserved for when an enemy is killed
const KILL_EXP_PERCENT: float = 0.25
const _MOVEMENT_ARROWS: PackedScene = preload("res://maps/map_tiles/movement_arrows.tscn")

## Unit's faction. Should be in the map's Faction stack.
@export var unit_name: String = "[Empty]"
@export_multiline var unit_description: String = "[Empty]"
@export var unit_class: UnitClass
@export var faction_id: int
@export var variant: String  # Visual variant.
@export var items: Array[Item]
@export var base_level: int = 1
@export var skills: Array[Skill] = [FollowUp.new()]

var total_exp: float
var level: int:
	set(value):
		total_exp = Unit.get_exp_from_level(value)
	get:
		return floori(Unit.get_level_from_exp(total_exp))
var personal_values: Dictionary
var effort_values: Dictionary
var current_movement: float
var dead: bool = false
var outline_highlight: bool = false
## Whether the unit is selected.
var selected: bool = false
var selectable: bool = true  # Whether the unit can be selected.
var waiting: bool = false
var sprite_animated: bool = true:
	set(value):
		sprite_animated = value
		if sprite_animated:
			_animation_player.play(_animation_player.current_animation)
		else:
			_animation_player.pause()
var weapon_levels: Dictionary
var traveler: Unit:
	set(value):
		traveler = value
		if traveler:
			_traveler_animation_player.play("display")
		else:
			_traveler_animation_player.play("RESET")
var personal_authority: int
var current_health: float:
	set(health):
		current_health = clampf(health, 0, get_stat(Stats.HIT_POINTS))
		if not Engine.is_editor_hint():
			const HealthBar = preload("res://units/health_bar/health_bar.gd")
			($HealthBar as HealthBar).update()
var faction: Faction:
	get:
		return (
			get_map().all_factions[faction_id]
			if get_map().all_factions.size() > 0
			else Faction.new("INVALID", Faction.Colors.BLUE, Faction.PlayerTypes.HUMAN, null)
		)
	set(new_faction):
		faction_id = get_map().all_factions.find(new_faction)

var _map: Map
var _animation_player: AnimationPlayer
var _traveler_animation_player: AnimationPlayer
var _portrait: Portrait
var _path: Array[Vector2i]  # Path the unit will follow when moving.
var _current_statuses: Array[Statuses]
var _movement_tiles_node: Node2D
var _attack_tile_node: Node2D
var _current_attack_tiles_node: Node2D
# Resources to be loaded.
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
static var _movement_speed: float = 16  # Speedunit moves across the map in tiles/second.
# Dictionaries that convert faction/variant into animation modifier.


func _enter_tree() -> void:
	_animation_player = $AnimationPlayer as AnimationPlayer
	_traveler_animation_player = $"TravelerIcon/AnimationPlayer" as AnimationPlayer
	level = base_level
	for weapon_type: Weapon.Types in unit_class.base_weapon_levels.keys() as Array[Weapon.Types]:
		if weapon_type not in weapon_levels.keys():
			weapon_levels[weapon_type] = lerpf(
				unit_class.base_weapon_levels[weapon_type] as float,
				unit_class.max_weapon_levels[weapon_type] as float,
				inverse_lerp(1, unit_class.max_level, level)
			)
	texture = unit_class.map_sprite
	material = material.duplicate() as Material
	current_movement = get_stat(Stats.MOVEMENT)
	current_health = get_stat(Stats.HIT_POINTS)
	add_to_group("units")
	_update_palette()
	if _animation_player.current_animation == "":
		_animation_player.play("idle")
	Utilities.sync_animation(_animation_player)
	var directory: String = "res://portraits/name/name.tscn".replace("name", unit_name.to_lower())
	if FileAccess.file_exists(directory):
		_portrait = (load(directory) as PackedScene).instantiate() as Portrait


func _exit_tree() -> void:
	_map.update_position_terrain_cost.call_deferred(position)


func _process(_delta: float) -> void:
	if traveler:
		traveler.position = position
	_render_status()
	if _animation_player.current_animation == "idle":
		var anim_frame: int = floori((Engine.get_physics_frames() as float) / 16) % 4
		frame = 1 if anim_frame == 3 else anim_frame
	z_index = Utilities.round_coords_to_tile(position).y
	(material as ShaderMaterial).set_shader_parameter("modulate", modulate)


func has_status(status: int) -> bool:
	return status in _current_statuses


func add_status(status: int) -> void:
	_current_statuses.append(status)


func remove_status(status: int) -> void:
	_current_statuses.erase(status)


func get_class_name() -> String:
	return unit_class.name


func get_current_weapon() -> Weapon:
	for item: Item in items:
		if item is Weapon and can_use_weapon(item as Weapon):
			return item as Weapon
	return null


## Attack without weapon triangle bonuses
func get_raw_attack() -> int:
	if get_current_weapon():
		var current_attack: int
		match get_current_weapon().get_damage_type():
			Weapon.DamageTypes.PHYSICAL:
				current_attack = get_stat(Stats.STRENGTH)
			Weapon.DamageTypes.RANGED:
				current_attack = get_stat(Stats.PIERCE)
			Weapon.DamageTypes.MAGIC:
				current_attack = get_stat(Stats.MAGIC)
		return get_current_weapon().might + current_attack
	return 0


func get_true_attack(enemy: Unit) -> int:
	return (
		(
			get_raw_attack()
			+ get_current_weapon().get_damage_bonus(enemy.get_current_weapon(), get_distance(enemy))
		)
		if get_current_weapon()
		else 0
	)


func get_damage(defender: Unit) -> int:
	return maxi(
		0,
		(
			get_true_attack(defender)
			- defender.get_current_defence(get_current_weapon().get_damage_type())
		)
	)


func get_crit_damage(defender: Unit) -> int:
	return maxi(
		0,
		(
			get_true_attack(defender) * 2
			- defender.get_current_defence(get_current_weapon().get_damage_type())
		)
	)


func set_animation(animation: Animations) -> void:
	_animation_player.play("RESET")
	_animation_player.advance(0)
	match animation:
		Animations.IDLE:
			_animation_player.play("idle")
		Animations.MOVING_LEFT:
			_animation_player.play("moving_left")
		Animations.MOVING_RIGHT:
			_animation_player.play("moving_right")
		Animations.MOVING_UP:
			_animation_player.play("moving_up")
		Animations.MOVING_DOWN:
			_animation_player.play("moving_down")
	if sprite_animated:
		Utilities.sync_animation(_animation_player)
	else:
		_animation_player.advance(0)
		_animation_player.pause()


func get_stat_boost(stat: Stats) -> int:
	return _stat_boosts.get(stat, 0)


func get_stat(stat: Stats, current_level: int = level) -> int:
	var weight: float = inverse_lerp(1, unit_class.max_level, current_level)
	var leveled_stat: float = lerpf(
		unit_class.base_stats.get(stat, 0), unit_class.end_stats.get(stat, 0), weight
	)
	var unclamped_stat: int = roundi(
		leveled_stat * _get_personal_value_multiplier(stat) * _get_effort_value_multiplier(stat)
	)
	return clampi(unclamped_stat, 0, get_stat_cap(stat)) + get_stat_boost(stat)


func get_stat_cap(stat: Stats) -> int:
	return roundi(
		(
			(unit_class.end_stats.get(stat, 0))
			* (1 + PERSONAL_VALUE_MULTIPLIER)
			* (1 + EFFORT_VALUE_MULTIPLIER)
		)
	)


func get_attack_speed() -> int:
	var weight: int = get_current_weapon().weight if get_current_weapon() else 0
	return get_stat(Stats.SPEED) - maxi(weight - get_stat(Stats.CONSTITUTION), 0)


func get_current_defence(attacker_weapon_type: Weapon.DamageTypes) -> int:
	match attacker_weapon_type:
		Weapon.DamageTypes.RANGED:
			return get_stat(Stats.ARMOR)
		Weapon.DamageTypes.MAGIC:
			return get_stat(Stats.RESISTANCE)
		Weapon.DamageTypes.PHYSICAL:
			return get_stat(Stats.DEFENSE)
		_:
			push_error("Damage Type %s Invalid" % attacker_weapon_type)
			return 0


func get_max_level() -> int:
	return 30


func get_area() -> Area2D:
	return $Area2D as Area2D


func get_portrait() -> Portrait:
	if _portrait:
		return _portrait.duplicate() as Portrait
	var portrait := Portrait.new()
	portrait.texture = unit_class.default_portrait
	portrait.centered = false
	portrait.material = ShaderMaterial.new()
	(portrait.material as ShaderMaterial).shader = preload("res://gba_color.gdshader")
	return portrait


func get_portrait_offset() -> Vector2i:
	return Vector2i(-8, 0) if _portrait else Vector2i()


func get_aid() -> int:
	var aid_mod: int = unit_class.aid_modifier
	return (
		get_stat(Stats.CONSTITUTION) + aid_mod if aid_mod <= 0
		else aid_mod - get_stat(Stats.CONSTITUTION)
	)


func get_weight() -> int:
	return get_stat(Stats.CONSTITUTION) + unit_class.weight_modifier


func get_hit() -> int:
	return get_current_weapon().hit + get_stat(Stats.SKILL) * 2 + get_stat(Stats.LUCK)


func get_avoid() -> int:
	return get_attack_speed() * 2 + get_stat(Stats.LUCK)


func get_hit_rate(enemy: Unit) -> int:
	return clampi(
		(
			get_hit()
			- enemy.get_avoid()
			+ get_current_weapon().get_hit_bonus(enemy.get_current_weapon(), get_distance(enemy))
		),
		0,
		100
	)


func get_crit() -> int:
	return get_current_weapon().crit + get_stat(Stats.SKILL)


func get_crit_avoid() -> int:
	return get_stat(Stats.LUCK)


func get_crit_rate(enemy: Unit) -> int:
	return clampi(get_crit() - enemy.get_crit_avoid(), 0, 100)


func get_path_last_pos() -> Vector2i:
	var path: Array[Vector2i] = get_unit_path()
	var unit_positions: Array[Vector2i] = []
	for unit: Unit in get_map().get_units():
		unit_positions.append(Vector2i(unit.position))
	while path.size() > 0:
		if path[-1] in unit_positions:
			path.erase(path[-1])
			continue
		return path[-1]
	return position


func get_stat_table(stat: Stats) -> Array[String]:
	var table_items: Dictionary = {
		"Class Base": str(unit_class.base_stats.get(stat, 0)),
		"Class Final": str(unit_class.end_stats.get(stat, 0)),
		"PersonalValues ": str(personal_values.get(stat, 0)),
		"EffortValues": str(effort_values.get(stat, 0)),
	}
	return Utilities.dict_to_table(table_items)


func get_min_range() -> int:
	var min_range: int = get_current_weapon().min_range
	for weapon: Item in items:
		if weapon is Weapon:
			min_range = mini((weapon as Weapon).min_range, min_range)
	return min_range


func get_max_range() -> int:
	var max_range: int = get_current_weapon().max_range
	for weapon: Item in items:
		if weapon is Weapon:
			max_range = maxi((weapon as Weapon).max_range, max_range)
	return max_range


func get_authority() -> int:
	return personal_authority + unit_class.authority


func get_distance(unit: Unit) -> int:
	return roundi(Utilities.get_tile_distance(position, unit.position))


func get_skills() -> Array[Skill]:
	return skills + unit_class.skills


func get_current_exp() -> float:
	return total_exp - Unit.get_exp_from_level(level)


static func get_exp_from_level(current_level: float) -> float:
	return BASE_EXP * (EXP_MULTIPLIER ** (current_level - 1) - 1)


static func get_level_from_exp(xp: float) -> float:
	return log(1 + float(xp) / BASE_EXP) / log(EXP_MULTIPLIER) + 1


static func get_exp_to_level(current_level: float) -> float:
	return get_exp_from_level(current_level) - get_exp_from_level(current_level - 1)


func get_exp_percent() -> int:
	return floori((roundf(get_current_exp()) / Unit.get_exp_to_level(level + 1)) * 100)


func has_skill_attribute(attrib: Skill.AllAttributes) -> bool:
	for skill: Skill in get_skills():
		if attrib in skill.attributes:
			return true
	return false


func can_use_weapon(weapon: Weapon) -> bool:
	return weapon.level <= weapon_levels.get(weapon.type, 0)


func can_rescue(unit: Unit) -> bool:
	return unit.get_weight() < get_aid() and is_friend(unit) and not traveler


## Causes unit to wait.
func wait() -> void:
	current_movement = get_stat(Stats.MOVEMENT)
	if Utilities.get_debug_constant("unit_wait"):
		selectable = false
		waiting = true
	get_map().unit_wait(self)
	_update_palette()


func die() -> void:
	dead = true
	AudioPlayer.play_sound_effect(preload("res://audio/sfx/death_fade.ogg"))
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, FADE_AWAY_DURATION)
	await tween.finished
	queue_free()


## Deselects unit.
func deselect() -> void:
	set_animation(Animations.IDLE)
	selected = false
	remove_path()
	if CursorController.hovered_unit == self:
		refresh_tiles()
	else:
		hide_movement_tiles()


## Un-waits unit.
func awaken() -> void:
	current_movement = get_stat(Stats.MOVEMENT)
	selectable = true
	waiting = false
	_update_palette()


func get_movement_tiles(custom_movement: int = floori(current_movement)) -> Array[Vector2i]:
	# Gets the movement tiles of the unit
	var h: Array[Vector2i] = []
	var start: Vector2i = position
	const RANGE_MULT: float = 4.0 / 3
	var movement_tiles_dict: Dictionary = {custom_movement as float: [start]}
	var movement_tiles: Array[Vector2i] = []
	if position == ((position / 16).floor() * 16):
		#region Gets the initial grid
		for y in range(-custom_movement * RANGE_MULT, custom_movement * RANGE_MULT + 1):
			var v := []
			for x in range(
				-(custom_movement * RANGE_MULT - absi(y)),
				(custom_movement * RANGE_MULT - absi(y)) + 1
			):
				v.append(start + Vector2i(x * 16, y * 16))
			h.append_array(v)
		#endregion
		#region Orders tiles by distance from center
		h.erase(start)
		for x: Vector2i in h:
			var movement_type: UnitClass.MovementTypes = unit_class.movement_type
			var cost: float = get_map().get_path_cost(
				movement_type, get_map().get_movement_path(movement_type, position, x, faction)
			)
			if cost <= current_movement:
				if not cost in movement_tiles_dict.keys():
					movement_tiles_dict[cost] = []
				(movement_tiles_dict[cost] as Array).append(x)
		#endregion
		for v: Array in movement_tiles_dict.values() as Array[Array]:
			var converted: Array[Vector2i] = []
			converted.assign(v)
			movement_tiles.append_array(converted)
	return movement_tiles


func get_all_attack_tiles(
	movement_tiles: Array[Vector2i] = get_movement_tiles()
) -> Array[Vector2i]:
	var all_attack_tiles: Array[Vector2i] = []
	if get_current_weapon():
		var basis_movement_tiles := movement_tiles.duplicate() as Array[Vector2i]
		for unit: Unit in get_map().get_units():
			if unit != self:
				var unit_pos: Vector2i = unit.position
				if unit_pos in basis_movement_tiles:
					basis_movement_tiles.erase(unit_pos)
		var min_range: int = get_min_range()
		var max_range: int = get_max_range()
		for tile: Vector2i in basis_movement_tiles:
			for y in range(-max_range, max_range + 1):
				for x in range(-max_range, max_range + 1):
					var attack_tile: Vector2i = tile + Vector2i(x * 16, y * 16)
					if (
						not (attack_tile in all_attack_tiles + movement_tiles)
						and get_map().borders.has_point(attack_tile)
					):
						var distance: int = floori(Utilities.get_tile_distance(tile, attack_tile))
						if distance >= min_range and distance <= max_range:
							all_attack_tiles.append(attack_tile)
	return all_attack_tiles


## Displays the unit's movement tiles.
func display_movement_tiles() -> void:
	hide_movement_tiles()
	var movement_tiles: Array[Vector2i] = get_movement_tiles()
	_movement_tiles_node = get_map().display_tiles(movement_tiles, Map.TileTypes.MOVEMENT, 1)
	_attack_tile_node = get_map().display_tiles(
		get_all_attack_tiles(movement_tiles), Map.TileTypes.ATTACK, 1
	)
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
	for y: int in range(-max_range, max_range + 1):
		var v: Array[Vector2i] = []
		for x: int in range(-max_range, max_range + 1):
			var distance: int = floori(Utilities.get_tile_distance(Vector2i(), Vector2i(x, y) * 16))
			if distance in range(min_range, max_range + 1):
				v.append(Vector2i(pos) + Vector2i(x * 16, y * 16))
		adjacent_tiles.append_array(v)
	return adjacent_tiles


func get_current_attack_tiles(pos: Vector2i, all_weapons: bool = false) -> Array[Vector2i]:
	if is_instance_valid(get_current_weapon()):
		var min_range: int = get_current_weapon().min_range
		var max_range: int = get_current_weapon().max_range
		if all_weapons:
			min_range = get_min_range()
			max_range = get_max_range()
		return get_adjacent_tiles(pos, min_range, max_range)
	return []


## Shows off the tiles the unit can attack from its current position.
func display_current_attack_tiles(pos: Vector2i) -> void:
	_current_attack_tiles_node = get_map().display_highlighted_tiles(
		get_current_attack_tiles(pos), self, Map.TileTypes.ATTACK
	)


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
	update_path(move_target)
	var path: Array[Vector2i] = get_unit_path()
	if move_target in path:
		remove_path()
		get_area().monitoring = false
		current_movement -= get_map().get_path_cost(unit_class.movement_type, path)
		while path.size() > 0:
			var target: Vector2 = path.pop_at(0)
			match target - position:
				Vector2(16, 0):
					set_animation(Animations.MOVING_RIGHT)
				Vector2(-16, 0):
					set_animation(Animations.MOVING_LEFT)
				Vector2(0, 16):
					set_animation(Animations.MOVING_DOWN)
				Vector2(0, -16):
					set_animation(Animations.MOVING_UP)
				_:
					set_animation(Animations.IDLE)

			while position != target:
				var tween: Tween = create_tween()
				tween.set_speed_scale(_movement_speed)
				tween.tween_method(
					func(new_pos: Vector2) -> void: position = new_pos.round(), position, target, 1
				)
				await tween.finished
		get_area().monitoring = true
		set_animation(Animations.IDLE)


func get_unit_path() -> Array[Vector2i]:
	return [position] as Array[Vector2i] if _path.size() == 0 else _path


func get_map() -> Map:
	if _map == null:
		var units_node: Node2D = get_parent()
		while units_node.name != "Units":
			units_node = units_node.get_parent()
		_map = units_node.get_parent().get_parent()
	return _map


## Gets the path of the unit.
func update_path(destination: Vector2i) -> void:
	if _path.size() == 0:
		_path.append(Vector2i(position))
	# Sets destination to an adjacent tile to a unit if a unit is hovered and over an attack tile.
	var movement_tiles: Array[Vector2i] = get_movement_tiles()
	var all_attack_tiles: Array[Vector2i] = get_all_attack_tiles(movement_tiles)
	if (
		not destination in movement_tiles
		and destination in all_attack_tiles
		and Utilities.get_tile_distance(get_unit_path()[-1], destination) > 1
	):
		for unit: Unit in get_map().get_units():
			if (
				Vector2i(unit.position) in all_attack_tiles
				and Vector2i(unit.position) == destination
			):
				var adjacent_movement_tiles: Array[Vector2i] = []
				for tile_offset: Vector2i in Utilities.adjacent_tiles:
					if Vector2i(unit.position) + tile_offset in movement_tiles:
						adjacent_movement_tiles.append(Vector2i(unit.position) + tile_offset)
				if adjacent_movement_tiles.size() > 0:
					adjacent_movement_tiles.shuffle()
					destination = (adjacent_movement_tiles)[0]
					break

	if destination in movement_tiles:
		# Gets the path
		var total_cost: float = 0
		for tile: Vector2i in _path:
			if tile != Vector2i(position):
				total_cost += get_map().get_terrain_cost(unit_class.movement_type, tile)
		if destination in _path:
			_path = _path.slice(0, _path.find(destination) + 1) as Array[Vector2i]
		else:
			if (
				total_cost <= current_movement
				and destination - get_unit_path()[-1] in Utilities.adjacent_tiles
			):
				_path.append(destination)
			else:
				var new_path: Array[Vector2i] = get_map().get_movement_path(
					unit_class.movement_type, position, destination, faction
				)
				_path = new_path


## Displays the unit's path
func show_path() -> void:
	if is_instance_valid(_arrows_container):
		_arrows_container.queue_free()
	_arrows_container = CanvasGroup.new()
	if get_unit_path().size() > 1:
		for i: Vector2i in get_unit_path():
			var tile := _MOVEMENT_ARROWS.instantiate() as Sprite2D
			var prev: Vector2i = i
			prev -= (
				Vector2i(position)
				if get_unit_path().find(i) == 0
				else get_unit_path()[get_unit_path().find(i) - 1]
			)
			var next: Vector2i
			if i != get_unit_path()[-1]:
				next = i - get_unit_path()[get_unit_path().find(i) + 1]
			if get_unit_path()[0] == i:
				match next:
					Vector2i(-16, 0):
						tile.frame = 0
					Vector2i(16, 0):
						tile.frame = 8
					Vector2i(0, 16):
						tile.frame = 7
					Vector2i(0, -16):
						tile.frame = 1
			elif i == get_unit_path()[-1]:
				match prev:
					Vector2i(16, 0):
						tile.frame = 4
					Vector2i(-16, 0):
						tile.frame = 12
					Vector2i(0, 16):
						tile.frame = 5
					Vector2i(0, -16):
						tile.frame = 11
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
			tile.position = Vector2(i)
			_arrows_container.add_child(tile)
		get_map().get_child(0).add_child(_arrows_container)


func get_new_map_attack() -> MapAttack:
	# Returns a new instance of the class's map attack animation
	return (load("res://map_attack.tscn") as PackedScene).instantiate() as MapAttack


func remove_path() -> void:
	# Removes the unit's path
	if is_instance_valid(_arrows_container):
		_arrows_container.queue_free()


func is_friend(other_unit: Unit) -> bool:
	return faction.is_friend(other_unit.faction)


func equip_weapon(weapon: Weapon) -> void:
	if weapon in items:
		items.erase(weapon)
		items.push_front(weapon)
	else:
		push_error('Tried equipping invalid weapon "%s" on unit "%s"' % [weapon.name, unit_name])


func drop(item: Item) -> void:
	items.erase(item)
	hide_movement_tiles()
	display_movement_tiles()


func _update_palette() -> void:
	if faction:
		_set_palette(faction.color)


func _render_status() -> void:
	pass


func _set_palette(color: Faction.Colors) -> void:
	var palette: Array[Array]
	#region sets palette
	match waiting:
		true:
			palette = _wait_palette
		false:
			match color:
				Faction.Colors.RED:
					palette = _red_palette
				Faction.Colors.GREEN:
					palette = _green_palette
				Faction.Colors.BLUE:
					palette = _default_palette
				Faction.Colors.PURPLE:
					palette = _purple_palette
				var invalid:
					palette = _default_palette
					push_error("Color %s does not have a palette." % invalid)
	#endregion
	var old_colors: Array[Color] = []
	var new_colors: Array[Color] = []
	for color_set in palette:
		var old_color: Vector3 = color_set[0] / 255
		old_colors.append(Color(old_color.x, old_color.y, old_color.z, 1))
		var new_color: Vector3 = color_set[1] / 255
		new_colors.append(Color(new_color.x, new_color.y, new_color.z, 1))
	var shader_material := material as ShaderMaterial
	shader_material.set_shader_parameter("old_colors", old_colors)
	shader_material.set_shader_parameter("new_colors", new_colors)


func _on_area2d_area_entered(area: Area2D) -> void:
	# When cursor enters unit's area
	if area == CursorController.get_area() and visible:
		var selecting: bool = MapController.selecting
		var can_be_selected: bool = true
		if is_instance_valid(CursorController.hovered_unit):
			var hovered_unit_selected: bool = CursorController.hovered_unit.selected
			can_be_selected = not hovered_unit_selected or selecting
		if can_be_selected and not (selected or selecting or waiting or dead):
			display_movement_tiles()
		CursorController.hovered_unit = self


func _get_personal_value_multiplier(stat: Stats) -> float:
	var personal_value: int = clampi(personal_values.get(stat, 5), 0, PERSONAL_VALUE_LIMIT)
	return 1 + ((personal_value as float) / PERSONAL_VALUE_LIMIT * PERSONAL_VALUE_MULTIPLIER)


func _get_effort_value_multiplier(stat: Stats) -> float:
	var effort_value: int = clampi(
		effort_values.get(stat, 0) as int, 0, INDIVIDUAL_EFFORT_VALUE_LIMIT
	)
	return 1 + ((effort_value as float) / INDIVIDUAL_EFFORT_VALUE_LIMIT * EFFORT_VALUE_MULTIPLIER)


func _on_area2d_area_exited(area: Area2D) -> void:
	# When cursor exits unit's area
	if area == CursorController.get_area() and not selected:
		hide_movement_tiles()
		cursor_exited.emit()
