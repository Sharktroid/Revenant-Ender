## A unit that can be controlled either by the player or the ai.
@tool
class_name Unit
extends UnitSprite

## Emits when the unit's health changes.
signal health_changed
## Emits when the unit arrives at its destination.
signal arrived
## Emits when the unit ends its turn.
signal turn_ended(action: String)
## The stats that a unit can have.
enum Stats {
	HIT_POINTS,
	STRENGTH,
	PIERCE,
	INTELLIGENCE,
	DEXTERITY,
	SPEED,
	LUCK,
	DEFENSE,
	ARMOR,
	RESISTANCE,
	MOVEMENT,
	BUILD,
}

## The amount of hit each point of dexterity gives.
const DEXTERITY_HIT_MULTIPLIER: int = 3
## The amount of avoid each point of speed or luck gives.
const SPEED_LUCK_AVOID_MULTIPLIER: int = 2
## The maximum level a unit can have.
const LEVEL_CAP: int = 30
## Duration of fade-away upon death
const FADE_AWAY_DURATION: float = 20.0 / 60
## The maximum amount of effort values a unit can have
const TOTAL_EFFORT_VALUE_LIMIT: float = INDIVIDUAL_EV_LIMIT * 4
## The experience required to go from level 1 to level 2
const BASE_EXP: int = 100
## The multiplier for the extra amount of experience to go from one level to the next
## compared to the previous level
const EXP_MULTIPLIER: float = 2 ** (1.0 / 2)
## The amount of experience for killing an enemy in one round of combat
const ONE_ROUND_EXP_BASE: float = float(BASE_EXP) / 3
## The amount of combat experience reserved for when an enemy is killed
const KILL_EXP_PERCENT: float = 0.25
## The default value for personal values.
const DEFAULT_PERSONAL_VALUE: int = 5
## Any rate below this value is set to 0%
const MIN_RATE: int = 5
## Any rate above this value is set to 100%
const MAX_RATE: int = 95
## The added amount when the stat is the unit class max and personal values are maxed
const PV_MAX_MODIFIER: int = 10
## The added amount when hit points are the unit class max and effort values are maxed
const EV_MAX_MODIFIER: int = 5
## The maximum value that a personal value can be
const PV_LIMIT: int = 15
## The maximum value that an EV can be
const INDIVIDUAL_EV_LIMIT: int = 250
## The amount of hit rates for every Authority over enemy's faction.
const AUTHORITY_HIT_BONUS: int = 4
## The amount of critical avoid given for every Authority over the enemy's faction.
const AUTHORITY_CRITICAL_AVOID_BONUS: int = 2

const _SAVED_PROPERTY_NAMES: Array[StringName] = [
	&"position",
	&"total_exp",
	&"traveler",
	&"personal_authority",
	&"current_health",
	&"waiting",
	&"unit_class",
	&"items",
	&"flip_h",
	&"dead",
	&"_faction_id",
	&"_personal_values",
	&"_effort_power",
	&"_effort_values",
	&"_equipped_weapon",
]
# The added amount when the stat is 0 and personal values are maxed
const _PV_MIN_MODIFIER: int = 5
# The added amount when hit points are 0 and personal values are maxed
const _PV_MIN_HP_MODIFIER: int = 10
# The added amount when hit points are the unit class max and personal values are maxed
const _PV_MAX_HP_MODIFIER: int = 20
# The added amount when the stat is 0 and effort values are maxed
const _EV_MIN_MODIFIER: int = EV_MAX_MODIFIER
# The added amount when the stat is 0 and effort values are maxed
const _EV_MIN_HP_MODIFIER: int = _EV_MAX_HP_MODIFIER
# The added amount when hit points are the unit class max and effort values are maxed
const _EV_MAX_HP_MODIFIER: int = EV_MAX_MODIFIER * 2

## The unit's name.
@export var display_name: String = "[Empty]"
## The unit's description.
@export_multiline var unit_description: String = "[Empty]"
## The items in the unit's inventory.
@export var items: Array[Item]

@export var _base_level: int = 1
@export var _personal_skills: Array[Skill]

## The total experience the unit has.
var total_exp: float
## Whether the unit is dead.
var dead: bool = false
## Whether the unit is selected.
var selected: bool = false
## Whether the unit can be selected.
var selectable: bool = true
## The unit's personal weapon levels.
var personal_weapon_levels: Dictionary[Weapon.Types, int]
## The unit being carried by the unit.
var traveler: Unit:
	set(value):
		traveler = value
		if traveler:
			_traveler_animation_player.play("display")
		else:
			_traveler_animation_player.play("RESET")
## The unit's personal authority.
var personal_authority: int

var _personal_values: Dictionary[Stats, int]
var _effort_power: int
var _effort_values: Dictionary[Stats, int]
# Comment to prevent formatter breaking things.
var _current_movement: float
var _attack_tiles := Set.new()
var _movement_tiles := Set.new()
var _portrait: Portrait
# Path the unit will follow when moving.
var _path: Array[Vector2i]
var _movement_tiles_node: Node2D
var _attack_tile_node: Node2D
var _current_attack_tiles_node: Node2D
# Resources to be loaded.
var _arrows_container: CanvasGroup
var _equipped_weapon: Weapon

## The unit's current level. Is derived from total_exp.
@onready var level: int:
	set(value):
		total_exp = Unit.get_exp_from_level(value)
	get:
		return floori(Unit.get_level_from_exp(total_exp))
## The unit's current health. If this drops to 0, the unit dies.
@onready var current_health: int = get_hit_points():
	set(health):
		current_health = clampi(health, 0, get_hit_points())
		if not Engine.is_editor_hint():
			const HealthBar: GDScript = preload("res://units/health_bar/health_bar.gd")
			($HealthBar as HealthBar).update()
		health_changed.emit()
@onready var _traveler_animation_player := $TravelerIcon/AnimationPlayer as AnimationPlayer


func _enter_tree() -> void:
	super()
	_reset_movement()
	add_to_group(&"units")
	var directory: String = "res://portraits/{name}/{name}.tscn".format(
		{"name": display_name.to_snake_case()}
	)
	if FileAccess.file_exists(directory):
		_portrait = (load(directory) as PackedScene).instantiate() as Portrait
	faction.name_changed.connect(_on_faction_name_changed)
	add_to_group(faction.get_group_name())
	flip_h = faction.flipped if faction else false
	level = _base_level


func _exit_tree() -> void:
	_get_map().update_position_terrain_cost.call_deferred(position)


func _process(_delta: float) -> void:
	super(_delta)
	if traveler:
		traveler.position = position
	_render_status()


## Gets the current weapon
func get_weapon() -> Weapon:
	if _equipped_weapon and _equipped_weapon in get_all_weapon_modes():
		return _equipped_weapon
	for item: Item in items:
		if item is Weapon and can_use_weapon(item as Weapon):
			return item as Weapon
	return null


## Equips a weapon
func equip_weapon(weapon: Weapon, shuffle: bool = true) -> void:
	if weapon in get_all_weapon_modes():
		_equipped_weapon = weapon
		if shuffle:
			items.erase(weapon)
			items.push_front(weapon)
	else:
		const UNFORMATTED_ERROR: String = 'Tried equipping invalid weapon "%s" on unit "%s"'
		push_error(UNFORMATTED_ERROR % [weapon.resource_name, display_name])


## Gets the quantity of the unit's current attack stat
func get_current_attack() -> int:
	if get_weapon():
		match get_weapon().get_damage_type():
			Weapon.DamageTypes.PHYSICAL:
				return get_strength()
			Weapon.DamageTypes.RANGED:
				return get_pierce()
			Weapon.DamageTypes.MAGICAL:
				return get_intelligence()
	return 0


## Attack without weapon triangle bonuses
func get_attack(initiation: bool) -> float:
	var attack: float = Formulas.ATTACK.evaluate(self)
	if get_weapon() is Spear and initiation:
		attack += (get_weapon() as Spear).get_initial_might() - get_weapon().get_might()
	return attack


## Gets the damage done with a normal attack
func get_damage(defender: Unit, initiation: bool) -> float:
	return maxf(0, get_true_attack(defender, initiation) - defender.get_current_defense(self))


## Gets the damage done with a crit
func get_crit_damage(defender: Unit, initiation: bool) -> float:
	var crit_damage: float = (
		get_true_attack(defender, initiation) * 2 - defender.get_current_defense(self)
	)
	return maxf(0, crit_damage)


## The displayed total damage dealt by the unit.
func get_displayed_damage(
	enemy: Unit, crit: bool, initiation: bool, check_miss: bool = true, check_crit: bool = true
) -> float:
	if get_hit_rate(enemy) <= 0 and check_miss:
		return 0
	else:
		if check_crit:
			var crit_rate: float = get_crit_rate(enemy)
			if crit_rate >= 100:
				return get_crit_damage(enemy, initiation)
			elif crit_rate <= 0:
				return get_damage(enemy, initiation)
		return get_crit_damage(enemy, initiation) if crit else get_damage(enemy, initiation)


func set_animation(animation: UnitSprite.Animations) -> void:
	flip_h = faction.flipped and animation == Animations.IDLE if faction else false
	super(animation)


## Gets the unit's stat
func get_stat(stat: Stats, current_level: int = level) -> int:
	return get_raw_stat(stat, current_level) + get_stat_boost(stat)


## Gets the unboosted stat, determined by class base and personal and effort values
func get_raw_stat(stat: Stats, current_level: int = level) -> int:
	var raw_stat: float = (
		unit_class.get_stat(stat, current_level)
		+ get_personal_modifier(stat, current_level)
		+ get_effort_modifier(stat)
	)
	return clampi(roundi(raw_stat), 0, get_stat_cap(stat))


## Gets the stat without factoring in level.
func get_base_stat(stat: Stats) -> int:
	return get_raw_stat(stat, 30)


## Gets the boost to a stat that is applied on top of the unit's raw stat
func get_stat_boost(stat: Stats) -> int:
	var total_boost: int = 0
	match stat:
		Stats.MOVEMENT:
			if traveler and traveler.get_weight() > float(get_aid()) / 2:
				var move_penalty: float = remap(
					traveler.get_weight(),
					float(get_aid()) / 2,
					get_aid(),
					0,
					float(get_raw_stat(Stats.MOVEMENT)) / 2
				)
				total_boost -= roundi(move_penalty)
	return total_boost


## Gets the unit's hit points
func get_hit_points(current_level: int = level) -> int:
	return get_stat(Stats.HIT_POINTS, current_level)


## Gets the unit's strength
func get_strength(current_level: int = level) -> int:
	return get_stat(Stats.STRENGTH, current_level)


## Gets the unit's pierce
func get_pierce(current_level: int = level) -> int:
	return get_stat(Stats.PIERCE, current_level)


## Gets the unit's intelligence
func get_intelligence(current_level: int = level) -> int:
	return get_stat(Stats.INTELLIGENCE, current_level)


## Gets the unit's dexterity
func get_dexterity(current_level: int = level) -> int:
	return get_stat(Stats.DEXTERITY, current_level)


## Gets the unit's speed
func get_speed(current_level: int = level) -> int:
	return get_stat(Stats.SPEED, current_level)


## Gets the unit's luck
func get_luck(current_level: int = level) -> int:
	return get_stat(Stats.LUCK, current_level)


## Gets the unit's defense
func get_defense(current_level: int = level) -> int:
	return get_stat(Stats.DEFENSE, current_level)


## Gets the unit's armor
func get_armor(current_level: int = level) -> int:
	return get_stat(Stats.ARMOR, current_level)


## Gets the unit's resistance
func get_resistance(current_level: int = level) -> int:
	return get_stat(Stats.RESISTANCE, current_level)


## Gets the unit's build
func get_build(current_level: int = level) -> int:
	return get_stat(Stats.BUILD, current_level)


## Gets the unit's movement
func get_movement(current_level: int = level) -> int:
	return get_stat(Stats.MOVEMENT, current_level)


## Gets the maximum amount of the stat possible
func get_stat_cap(stat: Stats) -> int:
	var max_stat: float = (
		unit_class.get_stat(stat, LEVEL_CAP) + get_personal_modifier(stat, LEVEL_CAP)
	)
	if stat == Stats.HIT_POINTS:
		return roundi(max_stat + _EV_MAX_HP_MODIFIER)
	elif stat == Stats.MOVEMENT:
		return roundi(max_stat + _EV_MIN_MODIFIER)
	else:
		return roundi(max_stat + EV_MAX_MODIFIER)


## Gets the speed after factoring in weight
func get_attack_speed() -> float:
	return Formulas.ATTACK_SPEED.evaluate(self)


## Gets the unit's defense type against a weapon
func get_current_defense(enemy: Unit) -> int:
	var authority_bonus: int = get_authority_modifier(enemy)
	match enemy.get_weapon().get_damage_type():
		Weapon.DamageTypes.PHYSICAL:
			return get_defense() + authority_bonus
		Weapon.DamageTypes.RANGED:
			return get_armor() + authority_bonus
		Weapon.DamageTypes.MAGICAL:
			return get_resistance() + authority_bonus
		var damage_type:
			push_error("Damage Type %s Invalid" % damage_type)
			return 0


## Gets the unit's portrait
func get_portrait() -> Portrait:
	if _portrait:
		return _portrait.duplicate() as Portrait
	else:
		var portrait := Portrait.new()
		portrait.texture = unit_class.get_default_portrait()
		portrait.centered = false
		portrait.material = ShaderMaterial.new()
		(portrait.material as ShaderMaterial).shader = preload("res://shaders/gba_color.gdshader")
		return portrait


## Gets the positional offset for the portrait
func get_portrait_offset() -> Vector2i:
	return Vector2i(-8, 0) if _portrait else Vector2i()


## Gets the aid for rescuing
func get_aid() -> int:
	var aid_mod: int = unit_class.get_aid_modifier()
	if aid_mod <= 0:
		return get_build() + aid_mod
	else:
		return aid_mod - get_build()


## Gets the unit's weight for rescuing purposes
func get_weight() -> int:
	return get_build() + unit_class.get_weight_modifier()


## Gets the base hit rate
func get_hit() -> float:
	return Formulas.HIT.evaluate(self)


## Gets the avoid, which reduces the enemy's hit
func get_avoid() -> float:
	return Formulas.AVOID.evaluate(self)


## Gets the hit rate against an enemy
func get_hit_rate(enemy: Unit) -> int:
	if get_weapon():  # No point in doing something more elaborate and complicated.
		var hit_bonus: float = get_weapon().get_hit_bonus(enemy.get_weapon(), _get_distance(enemy))
		var authority_bonus: int = AUTHORITY_HIT_BONUS * get_authority_modifier(enemy)
		return _adjust_rate(
			roundi(clampf(get_hit() - enemy.get_avoid() + hit_bonus + authority_bonus, 0, 100))
		)
	return 0


## Gets the base crit rate
func get_crit() -> float:
	return Formulas.CRIT.evaluate(self)


## Gets the critical avoid rate, or what reduces the enemy's crit rate
func get_critical_avoid() -> float:
	return Formulas.CRITICAL_AVOID.evaluate(self)


## Gets the crit rate against an enemy
func get_crit_rate(enemy: Unit) -> int:
	var critical_avoid: float = (
		enemy.get_critical_avoid()
		+ enemy.get_authority_modifier(self) * AUTHORITY_CRITICAL_AVOID_BONUS
	)
	return _adjust_rate(roundi(clampf(get_crit() - critical_avoid, 0, 100)))


## Gets the last position from the unit's path that a unit does not occupy
func get_path_last_pos() -> Vector2i:
	var path: Array[Vector2i] = get_unit_path().duplicate()
	var unit_positions := Set.new()
	var get_unit_position: Callable = func(unit: Unit) -> Vector2i: return unit.position
	unit_positions = Set.new(_get_map().get_units().map(get_unit_position))
	var valid_path: Array[Vector2i] = path.filter(
		func(tile: Vector2i) -> bool: return not unit_positions.has(tile)
	)
	return valid_path.back() if not valid_path.is_empty() else position


## Gets a table displaying the details of the unit's stats
func get_stat_table(stat: Stats) -> Table:
	var table_items: Dictionary[String, String] = {
		"Class Initial": str(roundi(unit_class.get_stat(stat, 1))),
		"Personal Value": str(get_personal_value(stat)),
		"Unboosted Value": str(get_raw_stat(stat)),
		"Class Final": str(roundi(unit_class.get_stat(stat, LEVEL_CAP))),
		"Effort Value": str(get_effort_value(stat)),
		"Modifier": _get_modifier(stat),
	}
	return Table.from_dictionary(table_items, 3)


## Gets the unit's weapons
func get_weapons() -> Array[Weapon]:
	var weapons: Array[Weapon] = []
	weapons.assign(items.filter(func(item: Item) -> bool: return item is Weapon))
	return weapons


## Gets the unit's minimum range.
func get_min_range() -> int:
	return get_all_weapon_modes().reduce(
		func(min_range: int, weapon: Weapon) -> int: return mini(min_range, weapon.get_min_range()),
		get_weapon().get_min_range()
	)


## Gets the unit's maximum range.
func get_max_range() -> float:
	var max_range_reduce: Callable = func(max_range: float, weapon: Weapon) -> float:
		return maxf(max_range, weapon.get_max_range())
	return get_all_weapon_modes().reduce(max_range_reduce, get_weapon().get_max_range())


## Gets the unit's skills
func get_skills() -> Array[Skill]:
	return _personal_skills + unit_class.get_skills()


## Gets the amount of experience gained after reaching the unit's level
func get_current_exp() -> float:
	return total_exp - Unit.get_exp_from_level(level)


## Gets the total experience to get to the level
static func get_exp_from_level(current_level: float) -> float:
	return BASE_EXP * (EXP_MULTIPLIER ** (current_level - 1) - 1) / (EXP_MULTIPLIER - 1)


## Gets the level that the amount of experience would have
static func get_level_from_exp(xp: float) -> float:
	return log(float(xp) * (EXP_MULTIPLIER - 1) / BASE_EXP + 1) / log(EXP_MULTIPLIER) + 1


## Gets the experience to get to a level from the previous level
static func get_exp_to_level(current_level: float) -> float:
	return get_exp_from_level(current_level) - get_exp_from_level(current_level - 1)


## Gets the percentage of experience to the next level
func get_exp_percent() -> int:
	return floori((roundf(get_current_exp()) / Unit.get_exp_to_level(level + 1)) * 100)


## Returns whether the unit can use the weapon
func can_use_weapon(weapon: Weapon) -> bool:
	return weapon.get_rank() <= get_weapon_level(weapon.get_type())


## Returns whether the unit can rescue the other unit
func can_rescue(unit: Unit) -> bool:
	return unit.get_weight() < get_aid() and is_friend(unit) and not traveler


## Causes unit to wait.
# TODO: rename to "end turn"
func wait(action_name: String = "waits") -> void:
	_reset_movement()
	if Options.UNIT_WAIT.value:
		waiting = true
	turn_ended.emit(action_name)
	deselect()


## Deselects unit.
func deselect() -> void:
	set_animation(Animations.IDLE)
	selected = false
	remove_path()
	if CursorController.get_hovered_unit() == self:
		update_displayed_tiles()
	else:
		hide_movement_tiles()


# TODO: rename to "refresh"
## Un-waits unit.
func awaken() -> void:
	_reset_movement()
	selectable = true
	waiting = false
	_update_palette()


## Gets the movement tiles of the unit
func get_movement_tiles() -> Set:
	if _movement_tiles.is_empty():
		var start: Vector2i = position
		const RANGE_MULTIPLIER: float = 4.0 / 3
		var movement_tiles_dict: Dictionary[float, Array] = {
			floorf(_current_movement) as float: [start]
		}
		if position == ((position / 16).floor() * 16):
			#region Gets the initial grid
			var h := Utilities.get_tiles(
				start, ceili(_current_movement * RANGE_MULTIPLIER), 0, MapController.map.borders
			)
			#endregion
			#region Orders tiles by distance from center
			h.erase(start)
			for x: Vector2i in h:
				var movement_type: UnitClass.MovementTypes = unit_class.get_movement_type()
				var cost: float = _get_map().get_path_cost(
					movement_type, _get_map().get_movement_path(movement_type, position, x, faction)
				)
				if cost <= _current_movement:
					if not movement_tiles_dict.has(cost):
						movement_tiles_dict[cost] = []
					(movement_tiles_dict[cost] as Array).append(x)
			#endregion
			for v: Array in movement_tiles_dict.values() as Array[Array]:
				_movement_tiles.append_array(v)
	return _movement_tiles.duplicate()


## Gets the movement tiles the unit can perform an action on.
func get_actionable_movement_tiles() -> Set:
	var movement_tiles: Set = get_movement_tiles()
	for unit: Unit in faction.get_units().filter(
		func(unit: Unit) -> bool: return unit != self and unit.visible
	):
		movement_tiles.erase(unit.position as Vector2i)
	return movement_tiles


## Gets all the tiles the unit can attack from.
func get_all_attack_tiles() -> Set:
	if _attack_tiles.is_empty() and get_weapon():
		var basis_movement_tiles: Set = get_actionable_movement_tiles()
		var min_range: int = get_min_range()
		var max_range: float = get_max_range()
		for tile: Vector2i in basis_movement_tiles:
			var attack_tiles := Utilities.get_tiles(
				tile, max_range, min_range, MapController.map.borders
			)
			var not_current_tile: Callable = func(attack_tile: Vector2i) -> bool:
				return not (_attack_tiles.has(attack_tile))
			_attack_tiles.append_set(attack_tiles.filter(not_current_tile))
	return _attack_tiles


## Displays the unit's movement tiles.
func display_movement_tiles() -> void:
	hide_movement_tiles()
	var movement_tiles: Set = get_movement_tiles()
	_movement_tiles_node = _get_map().display_tiles(movement_tiles, Map.TileTypes.MOVEMENT, 1)
	var filter: Callable = func(tile: Vector2i) -> bool: return not movement_tiles.has(tile)
	var attack_tiles: Set = get_all_attack_tiles().filter(filter)
	_attack_tile_node = _get_map().display_tiles(attack_tiles, Map.TileTypes.ATTACK, 1)
	if not selected:
		_movement_tiles_node.modulate.a = 0.5
		_attack_tile_node.modulate.a = 0.5


## Hides the unit's movement tiles.
func hide_movement_tiles() -> void:
	if is_instance_valid(_movement_tiles_node):
		_movement_tiles_node.queue_free()
		_attack_tile_node.queue_free()


## The tiles the unit can attack from its current position.
func get_current_attack_tiles(pos: Vector2i, all_weapons: bool = false) -> Set:
	if is_instance_valid(get_weapon()):
		var min_range: int = get_min_range() if all_weapons else get_weapon().get_min_range()
		var max_range: float = get_max_range() if all_weapons else get_weapon().get_max_range()
		return Utilities.get_tiles(pos, max_range, min_range, MapController.map.borders)
	return Set.new()


## Shows off the tiles the unit can attack from its current position.
func display_current_attack_tiles(
	all_weapons: bool = false, pos: Vector2i = get_unit_path().back()
) -> void:
	hide_current_attack_tiles()
	_current_attack_tiles_node = _get_map().display_highlighted_tiles(
		get_current_attack_tiles(pos, all_weapons), self, Map.TileTypes.ATTACK
	)


## Hides current attack tiles.
func hide_current_attack_tiles() -> void:
	if is_instance_valid(_current_attack_tiles_node):
		_current_attack_tiles_node.queue_free()


## Refreshes tiles
func update_displayed_tiles() -> void:
	if is_instance_valid(_movement_tiles_node):
		match selected:
			true:
				_movement_tiles_node.modulate.a = 1
				_attack_tile_node.modulate.a = 1
			false:
				_movement_tiles_node.modulate.a = .5
				_attack_tile_node.modulate.a = .5


## Moves unit to "move_target"
func move(move_target: Vector2i = get_unit_path()[-1]) -> void:
	hide_movement_tiles()
	update_path(move_target)
	var path: Array[Vector2i] = get_unit_path()
	if move_target in path:
		remove_path()
		_get_area().monitoring = false
		_current_movement -= _get_map().get_path_cost(unit_class.get_movement_type(), path)
		while not path.is_empty():
			var target: Vector2 = path.pop_at(0)
			_update_animation(target)
			while position != target:
				var speed: float = 1.0 / _get_movement_speed()
				if speed == 0:
					position = target
				else:
					var tween: Tween = create_tween()
					tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
					tween.tween_method(
						func(new_pos: Vector2) -> void: position = new_pos.round(),
						position,
						target,
						1.0 / _get_movement_speed()
					)
					await tween.finished
		_get_area().monitoring = true
		set_animation(Animations.IDLE)
		arrived.emit()
	reset_tile_cache()


## Gets the unit's path.
func get_unit_path() -> Array[Vector2i]:
	return [position] as Array[Vector2i] if _path.is_empty() else _path


## Gets array of stats where the modifier of PVs and EVs are static
static func get_fixed_stat_flags() -> int:
	return Utilities.to_flag(Stats.BUILD, Stats.MOVEMENT)


## Gets the path of the unit.
func update_path(destination: Vector2i) -> void:
	if _path.is_empty():
		_path.append(Vector2i(position))
	# Sets destination to an adjacent tile to a unit if a unit is hovered and over an attack tile.
	if _hovered_unit_in_range():
		var adjacent_movement_tiles: Set = _get_actionable_attack_tiles()
		if not adjacent_movement_tiles.is_empty():
			destination = _get_nearest_path_tile(adjacent_movement_tiles)
	if get_movement_tiles().has(destination):
		# Gets the path
		if destination in _path:
			_path = _path.slice(0, _path.find(destination) + 1) as Array[Vector2i]
		else:
			var path_end_adjacent_tiles: Set = Utilities.get_tiles(
				get_unit_path()[-1], 1, 1, _get_map().borders
			)
			if _get_path_cost() <= _current_movement and path_end_adjacent_tiles.has(destination):
				_path.append(destination)
			else:
				_path = _get_map().get_movement_path(
					unit_class.get_movement_type(), position, destination, faction
				)


## Displays the unit's path
func show_path() -> void:
	if is_instance_valid(_arrows_container):
		_arrows_container.queue_free()
	_arrows_container = CanvasGroup.new()
	if get_unit_path().size() > 1:
		for index: int in get_unit_path().size():
			_arrows_container.add_child(MovementArrow.instantiate(get_unit_path(), index))
		_get_map().get_child(0).add_child(_arrows_container)


## Removes the unit's path
func remove_path() -> void:
	if is_instance_valid(_arrows_container):
		_arrows_container.queue_free()


## Returns true if the other unit's faction is friends with the unit's faction
func is_friend(other_unit: Unit) -> bool:
	return faction.is_friend(other_unit.faction)


## Drops an item
func drop(item: Item) -> void:
	items.erase(item)
	reset_tile_cache()
	if _attack_tile_node:
		display_movement_tiles()


# FIXME: This is disgusting and there needs to be a better way to handle these. At least make this signal-based and not public.
## Resets the cached tiles
func reset_tile_cache() -> void:
	_movement_tiles = Set.new()
	_attack_tiles = Set.new()


## Returns true if the unit can follow up against the opponent.
func can_follow_up(opponent: Unit) -> bool:
	var follow_up_check: Callable = func(skill: Skill) -> bool:
		return skill is FollowUp and (skill as FollowUp).can_follow_up(self, opponent)
	return get_skills().any(follow_up_check)


## Gets the unit's authority
func get_authority() -> int:
	return personal_authority + unit_class.get_authority()


## Gets the true attack when attacking an enemy
func get_true_attack(enemy: Unit, initiation: bool) -> float:
	if get_weapon():
		var effectiveness_multiplier: int = (
			2 if get_weapon().get_effective_classes() & enemy.unit_class.get_armor_classes() else 1
		)
		var might: float = (
			get_attack(initiation)
			+ get_weapon().get_damage_bonus(enemy.get_weapon(), _get_distance(enemy))
			+ get_authority_modifier(enemy)
		)
		return effectiveness_multiplier * might
	return 0


## Gets the weapon level for a weapon type
func get_weapon_level(type: Weapon.Types) -> int:
	var faire_reduce: Callable = func(total_boost: int, skill: Skill) -> int:
		if skill is Faire and (skill as Faire).get_weapon_type() == type:
			return total_boost + (skill as Faire).get_rank_boost()
		return total_boost
	return unit_class.get_weapon_level(type) + get_skills().reduce(faire_reduce, 0)
	# Part of the classic weapon rank system.
	#var unclamped_level: int = (
	#	personal_weapon_levels.get(type, 0) as int
	#	+ unit_class.get_base_weapon_level(type)
	#	+ roundi(Formulas.WEAPON_LEVEL_BONUS.evaluate(self))
	#)
	#return clampi(unclamped_level, 0, unit_class.get_max_weapon_level(type))


# Part of the classic weapon rank system.
#func set_weapon_level(type: Weapon.Types, new_level: int) -> void:
#	if not personal_weapon_levels.get(type):
#		personal_weapon_levels[type] = 0
#		personal_weapon_levels[type] += (
#			clampi(new_level, 0, unit_class.get_max_weapon_level(type)) - get_weapon_level(type)
#		)


## Gets the unit's personal value for a stat.
func get_personal_value(stat: Stats) -> int:
	return _personal_values.get_or_add(
		stat, 0 if stat in [Stats.MOVEMENT, Stats.BUILD] else DEFAULT_PERSONAL_VALUE
	)


## Gets the unit's effort value for a stat.
func get_effort_value(stat: Stats) -> int:
	if stat & (1 << Stats.STRENGTH | 1 << Stats.PIERCE | 1 << Stats.INTELLIGENCE):
		return _effort_power
	else:
		return _effort_values.get(stat, 0)


func get_personal_modifier(stat: Stats, current_level: int = level) -> int:
	return _get_value_modifier(
		stat,
		current_level,
		_PV_MIN_HP_MODIFIER if stat == Stats.HIT_POINTS else _PV_MIN_MODIFIER,
		_PV_MAX_HP_MODIFIER if stat == Stats.HIT_POINTS else PV_MAX_MODIFIER,
		clampf(get_personal_value(stat), 0, PV_LIMIT) / PV_LIMIT
	)


func get_effort_modifier(stat: Stats, effort_value: int = get_effort_value(stat)) -> int:
	# Speedhack because min and max are equal
	# If defines/macros ever get implemented this should use those
	var modifier: int = _EV_MAX_HP_MODIFIER if stat == Stats.HIT_POINTS else EV_MAX_MODIFIER
	return roundi(modifier * clampf(effort_value, 0, INDIVIDUAL_EV_LIMIT) / INDIVIDUAL_EV_LIMIT)
	#return _get_value_modifier(
	#	stat,
	#	current_level,
	#	_EV_MIN_HP_MODIFIER if stat == Stats.HIT_POINTS else _EV_MIN_MODIFIER,
	#	_EV_MAX_HP_MODIFIER if stat == Stats.HIT_POINTS else EV_MAX_MODIFIER,
	#	clampf(effort_value, 0, INDIVIDUAL_EV_LIMIT) / INDIVIDUAL_EV_LIMIT
	#)


func get_authority_modifier(enemy: Unit) -> int:
	return maxi(faction.get_authority() - enemy.faction.get_authority(), 0)


## Saves the current state of the map. Faster than PackedScene.pack().
func quick_save() -> Dictionary[StringName, Variant]:
	var properties: Dictionary[StringName, Variant] = {&"scene_file_path": scene_file_path}
	for property_name: String in _SAVED_PROPERTY_NAMES:
		properties[property_name] = get(property_name)
	return properties


## Loads a dictionary returned from quick_save performed on this unit.
func quick_load(properties: Dictionary[StringName, Variant]) -> void:
	for property_name: String in _SAVED_PROPERTY_NAMES:
		set(property_name, properties[property_name])


## Creates a new unit, based off of a dictionary returned from quick_save.
static func full_load(properties: Dictionary[StringName, Variant], parent: Node) -> Unit:
	var unit_scene := load(properties.scene_file_path as String) as PackedScene
	var new_unit := unit_scene.instantiate() as Unit
	const _PRE_READY_PROPERTIES: Array[StringName] = [&"unit_class", &"_faction_id"]
	for property_name: StringName in _PRE_READY_PROPERTIES:
		new_unit.set(property_name, properties[property_name])
	parent.add_child(new_unit)
	new_unit.quick_load(properties)
	return new_unit


func get_sprite() -> UnitSprite:
	return UnitSprite.instantiate(
		unit_class,
		sprite_animated,
		waiting,
		faction,
		_custom_hair,
		_hair_color_light,
		_hair_color_dark
	)


func get_all_weapon_modes() -> Array[Weapon]:
	var get_all_modes: Callable = func(modes: Array[Weapon], weapon: Weapon) -> Array[Weapon]:
		return modes + weapon.get_weapon_modes()
	return get_weapons().filter(can_use_weapon).reduce(get_all_modes, [] as Array[Weapon])


func _set_faction_id(value: int) -> void:
	remove_from_group(faction.get_group_name())
	super(value)
	add_to_group(faction.get_group_name())


func _get_area() -> Area2D:
	return $Area2D as Area2D


func _get_distance(unit: Unit) -> int:
	return roundi(Utilities.get_tile_distance(position, unit.position))


func _update_animation(target: Vector2) -> void:
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


func _get_path_cost() -> float:
	var valid_path: Array[Vector2i] = _path.filter(
		func(tile: Vector2i) -> bool: return tile != Vector2i(position)
	)
	var sum_cost: Callable = func(sum: float, tile: Vector2i) -> float:
		return sum + _get_map().get_terrain_cost(unit_class.get_movement_type(), tile)
	return valid_path.reduce(sum_cost, 0)


func _get_actionable_attack_tiles() -> Set:
	var range_tiles: Set = Utilities.get_tiles(
		CursorController.get_hovered_unit().position,
		get_max_range(),
		get_min_range(),
		_get_map().borders
	)
	return Set.new(
		get_actionable_movement_tiles().to_array().filter(
			func(tile: Vector2i) -> bool: return range_tiles.has(tile)
		)
	)


func _die() -> void:
	dead = true
	AudioPlayer.play_sound_effect(preload("res://audio/sfx/death_fade.ogg"))
	var tween: Tween = create_tween()
	tween.tween_property(self, ^"modulate:a", 0, FADE_AWAY_DURATION)
	await tween.finished
	queue_free()


func _render_status() -> void:
	pass


# When cursor enters unit's area
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area == CursorController.get_area() and visible:
		var can_be_selected: bool = true
		if is_instance_valid(CursorController.get_hovered_unit()):
			can_be_selected = not CursorController.get_hovered_unit().selected
		if (
			can_be_selected
			and not (selected or dead)
			and _get_map().state == Map.States.SELECTING
			and CursorController.is_active()
		):
			display_movement_tiles()


# When cursor exits unit's area
func _on_area_2d_area_exited(area: Area2D) -> void:
	if area == CursorController.get_area() and not selected:
		hide_movement_tiles()


func _get_value_modifier(
	stat: Stats, current_level: int, min_value: float, max_value: float, value_weight: float
) -> int:
	if 1 << stat & get_fixed_stat_flags():
		return roundi((min_value if stat == Stats.MOVEMENT else max_value) * value_weight)
	else:
		return roundi(remap(current_level, 0, Unit.LEVEL_CAP, min_value, max_value) * value_weight)


func _hovered_unit_in_range() -> bool:
	if CursorController.get_hovered_unit():
		var hovered_position: Vector2i = Vector2i(CursorController.get_hovered_unit().position)
		return (
			not get_actionable_movement_tiles().has(hovered_position)
			and get_all_attack_tiles().has(hovered_position)
		)
	return false


func _get_nearest_path_tile(tiles: Set) -> Vector2i:
	while not _path.is_empty():
		if tiles.has(_path.back()):
			return _path.back()
		_path.pop_back()
	var weighted_tiles: Dictionary[int, Array] = {}
	for tile: Vector2i in tiles:
		var path: Array[Vector2i] = _get_map().get_movement_path(
			unit_class.get_movement_type(), position, tile, faction
		)
		var tile_cost: int = ceili(_get_map().get_path_cost(unit_class.get_movement_type(), path))
		if weighted_tiles.has(tile_cost):
			(weighted_tiles[tile_cost] as Array[Vector2i]).append(tile)
		else:
			weighted_tiles[tile_cost] = [tile]
	return (weighted_tiles[weighted_tiles.keys().min()] as Array[Vector2i]).pick_random()


# Gets the rate, with the min and max rates
func _adjust_rate(rate: int) -> int:
	if rate < MIN_RATE:
		return 0
	elif rate > MAX_RATE:
		return 100
	else:
		return rate


# Returns the unit movement speed in tiles/second.
func _get_movement_speed() -> float:
	const DEFAULT_SPEED: float = 16
	match Options.GAME_SPEED.value:
		Options.GAME_SPEED.SLOW:
			return 8
		Options.GAME_SPEED.NORMAL:
			return DEFAULT_SPEED
		Options.GAME_SPEED.FAST:
			return 80
		Options.GAME_SPEED.MAX:
			return INF
		_:
			push_error(Options.GAME_SPEED.get_error_message())
			return DEFAULT_SPEED


func _reset_movement() -> void:
	_current_movement = get_movement()


func _get_modifier(stat: Stats) -> String:
	if stat == Stats.SPEED and get_speed() != get_attack_speed():
		match sign(get_stat_boost(stat)) as int:
			-1:
				return "-({bonus} + {weight})".format(
					{"bonus": -get_stat_boost(stat), "weight": get_speed() - get_attack_speed()}
				)
			0:
				return str(get_attack_speed() - get_speed())
			_:
				return "{bonus} - {weight}".format(
					{"bonus": get_stat_boost(stat), "weight": get_speed() - get_attack_speed()}
				)
	else:
		return str(get_stat_boost(stat))


func _on_faction_name_changed(old_name: String) -> void:
	var old_faction := Faction.new(old_name, Faction.Colors.BLUE, Faction.PlayerTypes.HUMAN, null)
	remove_from_group(old_faction.get_group_name())
	add_to_group(faction.get_group_name())
