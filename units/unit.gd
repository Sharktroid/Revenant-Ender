@tool
class_name Unit
extends Sprite2D

signal health_changed
signal arrived

enum Animations { IDLE, MOVING_DOWN, MOVING_UP, MOVING_LEFT, MOVING_RIGHT }
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

const LEVEL_CAP: int = 30
## Duration of fade-away upon death
const FADE_AWAY_DURATION: float = 20.0 / 60
## The maximum amount of effort values a unit can have
const TOTAL_EFFORT_VALUE_LIMIT: float = _INDIVIDUAL_EV_LIMIT * 4
## The experience required to go from level 1 to level 2
const BASE_EXP: int = 100
## The multiplier for the extra amount of experience to go from one level to the next
## compared to the previous level
const EXP_MULTIPLIER: float = 2 ** (1.0 / 2)
## The amount of experience for killing an enemy in one round of combat
const ONE_ROUND_EXP_BASE: float = float(BASE_EXP) / 3
## The amount of combat experience reserved for when an enemy is killed
const KILL_EXP_PERCENT: float = 0.25
const DEFAULT_PERSONAL_VALUE: int = 5
const MAX_LEVEL: int = 30
## Any rate below this value is set to 0%
const MIN_RATE: int = 5
## Any rate above this value is set to 100%
const MAX_RATE: int = 95
## The added amount when the stat is the unit class max and personal values are maxed
const PV_MAX_MODIFIER: float = 5
## The added amount when hit points are the unit class max and effort values are maxed
const EV_MAX_MODIFIER: float = 5
## The bonus to hit rates per extra authority star over enemy's faction.
const AUTHORITY_HIT_BONUS: int = 5

# The added amount when the stat is 0 and personal values are maxed
const _PV_MIN_MODIFIER: float = 2.5
# The added amount when hit points are 0 and personal values are maxed
const _PV_MIN_HP_MODIFIER: float = 5
# The added amount when hit points are the unit class max and personal values are maxed
const _PV_MAX_HP_MODIFIER: float = 10
# The added amount when the stat is 0 and effort values are maxed
const _EV_MIN_MODIFIER: float = 2.5
# The added amount when the stat is 0 and effort values are maxed
const _EV_MIN_HP_MODIFIER: float = 5
# The added amount when hit points are the unit class max and effort values are maxed
const _EV_MAX_HP_MODIFIER: float = 10
# The maximum value that a personal value can be
const _PV_LIMIT: int = 15
# The maximum value that an EV can be
const _INDIVIDUAL_EV_LIMIT: int = 250

@export var display_name: String = "[Empty]"
@export_multiline var unit_description: String = "[Empty]"
@export var unit_class: UnitClass
@export var items: Array[Item]

## Unit's faction. Should be in the map's Faction stack.
@export var _faction_id: int
@export var _base_level: int = 1
@export var _personal_skills: Array[Skill]

@export_group("Hair")
@export var _custom_hair: bool = false
@export_color_no_alpha var _hair_color_light: Color
@export_color_no_alpha var _hair_color_dark: Color

var total_exp: float
var level: int:
	set(value):
		total_exp = Unit.get_exp_from_level(value)
	get:
		return floori(Unit.get_level_from_exp(total_exp))
var dead: bool = false
## Whether the unit is selected.
var selected: bool = false
## Whether the unit can be selected.
var selectable: bool = true
var sprite_animated: bool = true:
	set(value):
		sprite_animated = value
		if sprite_animated:
			_animation_player.play(_animation_player.current_animation)
		else:
			_animation_player.pause()
var personal_weapon_levels: Dictionary
var traveler: Unit:
	set(value):
		traveler = value
		if traveler:
			_traveler_animation_player.play("display")
		else:
			_traveler_animation_player.play("RESET")
var personal_authority: int
var current_health: int:
	set(health):
		current_health = clampi(health, 0, get_hit_points())
		if not Engine.is_editor_hint():
			const HealthBar = preload("res://units/health_bar/health_bar.gd")
			($HealthBar as HealthBar).update()
		health_changed.emit()
var faction: Faction:
	get:
		if _get_map() and not _get_map().all_factions.is_empty():
			return _get_map().all_factions[_faction_id]
		return Faction.new("INVALID", Faction.Colors.BLUE, Faction.PlayerTypes.HUMAN, null)
	set(new_faction):
		_faction_id = _get_map().all_factions.find(new_faction)
var waiting: bool = false

## Effort value for hit points
var effort_hit_points: int
## Effort value for strength, pierce, and intelligence
var effort_power: int
## Effort value for dexterity
var effort_dexterity: int
## Effort value for speed
var effort_speed: int
## Effort value for luck
var effort_luck: int
## Effort value for defense
var effort_defense: int
## Effort value for armor
var effort_armor: int
## Effort value for resistance
var effort_resistance: int
## Effort value for movement
var effort_movement: int
## Effort value for build
var effort_build: int

# Ignore warnings as these are called via "get" command (see get_stat)
@warning_ignore("unused_private_class_variable")
var _personal_hit_points: int = DEFAULT_PERSONAL_VALUE
@warning_ignore("unused_private_class_variable")
var _personal_strength: int = DEFAULT_PERSONAL_VALUE
@warning_ignore("unused_private_class_variable")
var _personal_pierce: int = DEFAULT_PERSONAL_VALUE
@warning_ignore("unused_private_class_variable")
var _personal_intelligence: int = DEFAULT_PERSONAL_VALUE
@warning_ignore("unused_private_class_variable")
var _personal_dexterity: int = DEFAULT_PERSONAL_VALUE
@warning_ignore("unused_private_class_variable")
var _personal_speed: int = DEFAULT_PERSONAL_VALUE
@warning_ignore("unused_private_class_variable")
var _personal_luck: int = DEFAULT_PERSONAL_VALUE
@warning_ignore("unused_private_class_variable")
var _personal_defense: int = DEFAULT_PERSONAL_VALUE
@warning_ignore("unused_private_class_variable")
var _personal_armor: int = DEFAULT_PERSONAL_VALUE
@warning_ignore("unused_private_class_variable")
var _personal_resistance: int = DEFAULT_PERSONAL_VALUE
@warning_ignore("unused_private_class_variable")
var _personal_movement: int
@warning_ignore("unused_private_class_variable")
var _personal_build: int = DEFAULT_PERSONAL_VALUE

var _current_movement: float
var _attack_tiles: Array[Vector2i]
var _movement_tiles: Array[Vector2i]
var _map: Map
var _animation_player: AnimationPlayer
var _traveler_animation_player: AnimationPlayer
var _portrait: Portrait
var _path: Array[Vector2i]  # Path the unit will follow when moving.
var _movement_tiles_node: Node2D
var _attack_tile_node: Node2D
var _current_attack_tiles_node: Node2D
# Resources to be loaded.
var _arrows_container: CanvasGroup


func _enter_tree() -> void:
	_animation_player = $AnimationPlayer as AnimationPlayer
	_traveler_animation_player = $TravelerIcon/AnimationPlayer as AnimationPlayer
	level = _base_level
	texture = unit_class.get_map_sprite()
	material = material.duplicate() as Material
	_reset_movement()
	current_health = get_hit_points()
	add_to_group("units")
	_update_palette()
	if _animation_player.current_animation == "":
		_animation_player.play("idle")
	Utilities.sync_animation(_animation_player)
	var directory: String = "res://portraits/{name}/{name}.tscn".format(
		{"name": display_name.to_snake_case()}
	)
	if FileAccess.file_exists(directory):
		_portrait = (load(directory) as PackedScene).instantiate() as Portrait


func _exit_tree() -> void:
	_get_map().update_position_terrain_cost.call_deferred(position)


func _process(_delta: float) -> void:
	if traveler:
		traveler.position = position
	_render_status()
	if _animation_player.current_animation == "idle":
		var anim_frame: int = floori((Engine.get_physics_frames() as float) / 16) % 4
		frame = 1 if anim_frame == 3 else anim_frame


## Gets the current weapon
func get_weapon() -> Weapon:
	for item: Item in items:
		if item is Weapon and can_use_weapon(item as Weapon):
			return item as Weapon
	return null


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
func get_attack() -> float:
	return Formulas.ATTACK.evaluate(self)


## Gets the damage done with a normal attack
func get_damage(defender: Unit) -> float:
	return maxf(0, get_true_attack(defender) - defender.get_current_defense(self))


## Gets the damage done with a crit
func get_crit_damage(defender: Unit) -> float:
	return maxf(0, get_true_attack(defender) * 2 - defender.get_current_defense(self))


## Sets the unit's map animation
func set_animation(animation: Animations) -> void:
	_animation_player.play("RESET")
	_animation_player.advance(0)
	flip_h = faction.flipped and animation == Animations.IDLE if faction else false
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


## Gets the unit's stat
func get_stat(stat: Stats, current_level: int = level) -> int:
	return get_raw_stat(stat, current_level) + get_stat_boost(stat)


## Gets the unboosted stat, determined by class base and personal and effort values
func get_raw_stat(stat: Stats, current_level: int = level) -> int:
	var raw_stat: float = (
		unit_class.get_stat(stat, current_level)
		+ _get_personal_modifier(stat, current_level)
		+ _get_effort_modifier(stat, current_level)
	)
	return clampi(roundi(raw_stat), 0, get_stat_cap(stat))


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
		unit_class.get_stat(stat, MAX_LEVEL) + _get_personal_modifier(stat, MAX_LEVEL)
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
	var authority_bonus: int = maxi(faction.get_authority() - enemy.faction.get_authority(), 0)
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
	var hit_bonus: int = get_weapon().get_hit_bonus(enemy.get_weapon(), _get_distance(enemy))
	var authority_bonus: int = (
		AUTHORITY_HIT_BONUS * maxi(faction.get_authority() - enemy.faction.get_authority(), 0)
	)
	return _adjust_rate(
		roundi(clampf(get_hit() - enemy.get_avoid() + hit_bonus + authority_bonus, 0, 100))
	)


## Gets the base crit rate
func get_crit() -> float:
	return Formulas.CRIT.evaluate(self)


## Gets the dodge rate, or what reduces the enemy's crit rate
func get_dodge() -> float:
	return Formulas.DODGE.evaluate(self)


## Gets the crit rate against an enemy
func get_crit_rate(enemy: Unit) -> int:
	return _adjust_rate(roundi(clampf(get_crit() - enemy.get_dodge(), 0, 100)))


## Gets the last position from the unit's path that a unit does not occupy
func get_path_last_pos() -> Vector2i:
	var path: Array[Vector2i] = get_unit_path().duplicate()
	var unit_positions: Array[Vector2i] = []
	unit_positions.assign(
		_get_map().get_units().map(func(unit: Unit) -> Vector2i: return unit.position)
	)
	var valid_path: Array[Vector2i] = path.filter(
		func(tile: Vector2i) -> bool: return tile not in unit_positions
	)
	return valid_path.back() if not valid_path.is_empty() else position


## Gets a table displaying the details of the unit's stats
func get_stat_table(stat: Stats) -> Array[String]:
	var table_items: Dictionary = {
		"Class Initial": str(roundi(unit_class.get_stat(stat, 1))),
		"Personal Value": str(_get_personal_value(stat)),
		"Unboosted Value": str(get_raw_stat(stat)),
		"Class Final": str(unit_class.get_stat(stat, MAX_LEVEL)),
		"Effort Value": str(_get_effort_value(stat)),
		"Modifier": _get_modifier(stat),
	}
	return Utilities.dict_to_table(table_items)


## Gets the unit's weapons
func get_weapons() -> Array[Weapon]:
	var weapons: Array[Weapon] = []
	weapons.assign(items.filter(func(item: Item) -> bool: return item is Weapon))
	return weapons


## Gets the unit's minimum range.
func get_min_range() -> int:
	return get_weapons().reduce(
		func(min_range: int, weapon: Weapon) -> int: return mini(min_range, weapon.get_min_range()),
		get_weapon().get_min_range()
	)


## Gets the unit's maximum range.
func get_max_range() -> float:
	var max_range_reduce: Callable = func(max_range: float, weapon: Weapon) -> float:
		return maxf(max_range, weapon.get_max_range())
	return get_weapons().reduce(max_range_reduce, get_weapon().get_max_range())


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
func wait() -> void:
	_reset_movement()
	if DebugConfig.UNIT_WAIT.value:
		waiting = true
	_get_map().unit_wait(self)
	_update_palette()
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


## Un-waits unit.
func awaken() -> void:
	_reset_movement()
	selectable = true
	waiting = false
	_update_palette()


## Gets the movement tiles of the unit
func get_movement_tiles() -> Array[Vector2i]:
	if _movement_tiles.is_empty():
		var start: Vector2i = position
		const RANGE_MULTIPLIER: float = 4.0 / 3
		var movement_tiles_dict: Dictionary = {floori(_current_movement) as float: [start]}
		if position == ((position / 16).floor() * 16):
			#region Gets the initial grid
			var h: Array[Vector2i] = Utilities.get_tiles(
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
					if not cost in movement_tiles_dict.keys():
						movement_tiles_dict[cost] = []
					(movement_tiles_dict[cost] as Array).append(x)
			#endregion
			for v: Array in movement_tiles_dict.values() as Array[Array]:
				var converted: Array[Vector2i] = []
				converted.assign(v)
				_movement_tiles.append_array(converted)
	return _movement_tiles.duplicate()


## Gets the movement tiles the unit can perform an action on.
func get_actionable_movement_tiles() -> Array[Vector2i]:
	var movement_tiles: Array[Vector2i] = get_movement_tiles()
	for unit: Unit in faction.get_units().filter(
		func(unit: Unit) -> bool: return unit != self and unit.visible
	):
		movement_tiles.erase(unit.position as Vector2i)
	return movement_tiles


## Gets all the tiles the unit can attack.
func get_all_attack_tiles() -> Array[Vector2i]:
	if _attack_tiles.is_empty() and get_weapon():
		var basis_movement_tiles: Array[Vector2i] = get_actionable_movement_tiles()
		var min_range: int = get_min_range()
		var max_range: float = get_max_range()
		var base_sub_tiles: Array[Vector2i] = Utilities.get_tiles(Vector2i(), min_range, 1)
		var has_sub_tiles: Callable = func(tile: Vector2i) -> bool:
			var has_sub_tile: Callable = func(subtile: Vector2i) -> bool:
				return not tile + subtile in get_movement_tiles()
			return base_sub_tiles.any(has_sub_tile)
		for tile: Vector2i in basis_movement_tiles.filter(has_sub_tiles):
			var attack_tiles: Array[Vector2i] = Utilities.get_tiles(
				tile, max_range, min_range, MapController.map.borders
			)
			var not_current_tile: Callable = func(attack_tile: Vector2i) -> bool:
				return not (attack_tile in _attack_tiles + get_movement_tiles())
			_attack_tiles.append_array(attack_tiles.filter(not_current_tile))
	return _attack_tiles


## Displays the unit's movement tiles.
func display_movement_tiles() -> void:
	hide_movement_tiles()
	_movement_tiles_node = _get_map().display_tiles(get_movement_tiles(), Map.TileTypes.MOVEMENT, 1)
	_attack_tile_node = _get_map().display_tiles(get_all_attack_tiles(), Map.TileTypes.ATTACK, 1)
	if not selected:
		_movement_tiles_node.modulate.a = 0.5
		_attack_tile_node.modulate.a = 0.5


## Hides the unit's movement tiles.
func hide_movement_tiles() -> void:
	if is_instance_valid(_movement_tiles_node):
		_movement_tiles_node.queue_free()
		_attack_tile_node.queue_free()


func get_current_attack_tiles(pos: Vector2i, all_weapons: bool = false) -> Array[Vector2i]:
	if is_instance_valid(get_weapon()):
		var min_range: int = get_min_range() if all_weapons else get_weapon().get_min_range()
		var max_range: float = get_max_range() if all_weapons else get_weapon().get_max_range()
		return Utilities.get_tiles(pos, max_range, min_range, MapController.map.borders)
	return []


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
static func get_fixed_stats() -> Array[Stats]:
	return [Stats.BUILD, Stats.MOVEMENT]


## Gets the path of the unit.
func update_path(destination: Vector2i) -> void:
	if _path.is_empty():
		_path.append(Vector2i(position))
	# Sets destination to an adjacent tile to a unit if a unit is hovered and over an attack tile.
	if (
		CursorController.get_hovered_unit()
		and Vector2i(CursorController.get_hovered_unit().position) in get_all_attack_tiles()
	):
		var actionable_movement_tiles: Array[Vector2i] = get_actionable_movement_tiles()
		var adjacent_movement_tiles: Array[Vector2i] = []
		for tile: Vector2i in Utilities.get_tiles(
			CursorController.get_hovered_unit().position,
			get_max_range(),
			get_min_range(),
			_get_map().borders
		):
			if tile in actionable_movement_tiles:
				adjacent_movement_tiles.append(tile)
		if not adjacent_movement_tiles.is_empty():
			destination = _get_nearest_path_tile(adjacent_movement_tiles)
	if destination in get_movement_tiles():
		# Gets the path
		var valid_path: Array[Vector2i] = _path.filter(
			func(tile: Vector2i) -> bool: return tile != Vector2i(position)
		)
		var sum_cost: Callable = func(sum: float, tile: Vector2i) -> float:
			return sum + _get_map().get_terrain_cost(unit_class.get_movement_type(), tile)
		var total_cost: float = valid_path.reduce(sum_cost, 0)
		if destination in _path:
			_path = _path.slice(0, _path.find(destination) + 1) as Array[Vector2i]
		else:
			var path_end_adjacent_tiles: Array[Vector2i] = Utilities.get_tiles(
				get_unit_path()[-1], 1, 1, _get_map().borders
			)
			if total_cost <= _current_movement and destination in path_end_adjacent_tiles:
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


## Equips a weapon
func equip_weapon(weapon: Weapon) -> void:
	if weapon in items:
		items.erase(weapon)
		items.push_front(weapon)
	else:
		const UNFORMATTED_ERROR: String = 'Tried equipping invalid weapon "%s" on unit "%s"'
		push_error(UNFORMATTED_ERROR % [weapon.resource_name, display_name])


## Drops an item
func drop(item: Item) -> void:
	items.erase(item)
	reset_tile_cache()
	if _attack_tile_node:
		display_movement_tiles()


## Resets the cached tiles
func reset_tile_cache() -> void:
	_movement_tiles = []
	_attack_tiles = []


## Returns true if the unit can follow up against the opponent.
func can_follow_up(opponent: Unit) -> bool:
	var is_follow_up: Callable = func(skill: Skill) -> bool: return skill is FollowUp
	var follow_up_check: Callable = func(skill: FollowUp) -> bool:
		return skill.can_follow_up(self, opponent)
	return get_skills().filter(is_follow_up).any(follow_up_check)


## Gets the unit's authority
func get_authority() -> int:
	return personal_authority + unit_class.get_authority()


## Gets the true attack when attacking an enemy
func get_true_attack(enemy: Unit) -> float:
	if get_weapon():
		return (
			get_attack()
			+ get_weapon().get_damage_bonus(enemy.get_weapon(), _get_distance(enemy))
			+ maxi(faction.get_authority() - enemy.faction.get_authority(), 0)
		)
	return 0


## Gets the weapon level for a weapon type
func get_weapon_level(type: Weapon.Types) -> int:
	var unclamped_level: int = (
		personal_weapon_levels.get(type, 0) as int
		+ unit_class.get_base_weapon_level(type)
		+ roundi(Formulas.WEAPON_LEVEL_BONUS.evaluate(self))
	)
	return clampi(unclamped_level, 0, unit_class.get_max_weapon_level(type))


## Sets the weapon level of a type
func set_weapon_level(type: Weapon.Types, new_level: int) -> void:
	if not personal_weapon_levels.get(type):
		personal_weapon_levels[type] = 0
	personal_weapon_levels[type] += (
		clampi(new_level, 0, unit_class.get_max_weapon_level(type)) - get_weapon_level(type)
	)


func _get_area() -> Area2D:
	return $Area2D as Area2D


func _get_map() -> Map:
	if _map == null:
		if Engine.is_editor_hint():
			var current_parent: Node = get_parent()
			while current_parent is not Map and current_parent:
				current_parent = current_parent.get_parent()
			return current_parent as Map
		else:
			return MapController.map
	return _map


func _update_palette() -> void:
	var shader_material := material as ShaderMaterial
	shader_material.set_shader_parameter("old_colors", unit_class.get_palette_basis())
	var get_palette: Callable = func() -> Array[Color]:
		if waiting:
			return unit_class.get_wait_palette() + _get_grayscale_hair_palette()
		else:
			return (
				unit_class.get_palette(faction.color if faction else Faction.Colors.BLUE)
				+ _get_hair_palette()
			)
	shader_material.set_shader_parameter("new_colors", get_palette.call())


func _get_distance(unit: Unit) -> int:
	return roundi(Utilities.get_tile_distance(position, unit.position))


func _get_personal_value(stat: Stats) -> int:
	return get("_personal_%s" % (Unit.Stats.find_key(stat) as String).to_snake_case())


func _get_effort_value(stat: Stats) -> int:
	if stat in [Stats.STRENGTH, Stats.PIERCE, Stats.INTELLIGENCE]:
		return effort_power
	else:
		return get("effort_%s" % (Unit.Stats.find_key(stat) as String).to_snake_case())


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
func _on_area2d_area_entered(area: Area2D) -> void:
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
func _on_area2d_area_exited(area: Area2D) -> void:
	if area == CursorController.get_area() and not selected:
		hide_movement_tiles()


func _get_personal_modifier(stat: Stats, current_level: int) -> float:
	return _get_value_modifier(
		stat,
		current_level,
		_PV_MIN_HP_MODIFIER if stat == Stats.HIT_POINTS else _PV_MIN_MODIFIER,
		_PV_MAX_HP_MODIFIER if stat == Stats.HIT_POINTS else PV_MAX_MODIFIER,
		clampf(_get_personal_value(stat) as int, 0, _PV_LIMIT) / _PV_LIMIT
	)


func _get_effort_modifier(stat: Stats, current_level: int) -> float:
	return _get_value_modifier(
		stat,
		current_level,
		_EV_MIN_HP_MODIFIER if stat == Stats.HIT_POINTS else _EV_MIN_MODIFIER,
		_EV_MAX_HP_MODIFIER if stat == Stats.HIT_POINTS else EV_MAX_MODIFIER,
		clampf(_get_effort_value(stat) as int, 0, _INDIVIDUAL_EV_LIMIT) / _INDIVIDUAL_EV_LIMIT
	)


func _get_value_modifier(
	stat: Stats, current_level: int, min_value: float, max_value: float, value_weight: float
) -> float:
	if stat in get_fixed_stats():
		return (min_value if stat == Stats.MOVEMENT else max_value) * value_weight
	else:
		var stat_modifier: float = remap(
			unit_class.get_stat(stat, current_level),
			UnitClass.MIN_HIT_POINTS if stat == Stats.HIT_POINTS else 0,
			UnitClass.MAX_HIT_POINTS if stat == Stats.HIT_POINTS else UnitClass.MAX_END_STAT,
			min_value,
			max_value
		)
		return stat_modifier * value_weight


func _get_hair_palette() -> Array[Color]:
	var default_palette: Array[Color] = unit_class.get_default_hair_palette(
		faction.color if faction else Faction.Colors.BLUE
	)
	if _custom_hair:
		var palette_length: int = default_palette.size()
		var palette: Array[Color] = []
		var get_hair_color: Callable = func(index: int) -> Color:
			return _hair_color_light.lerp(
				_hair_color_dark, inverse_lerp(0, palette_length - 1, index)
			)
		palette.assign(range(palette_length).map(get_hair_color))
		return palette
	else:
		return default_palette


func _get_grayscale_hair_palette() -> Array[Color]:
	var default_palette: Array[Color] = unit_class.get_default_hair_palette(faction.color)
	if _custom_hair:
		var palette_length: int = default_palette.size()
		var palette: Array[Color] = []
		var get_grayscale_color: Callable = func(index: int) -> Color:
			var new_color := Color()
			new_color.v = remap(index, 0, palette_length, _hair_color_light.v, _hair_color_dark.v)
			return new_color
		palette.assign(range(palette_length).map(get_grayscale_color))
		return palette
	else:
		return default_palette


func _get_nearest_path_tile(tiles: Array[Vector2i]) -> Vector2i:
	while not _path.is_empty():
		if _path.back() in tiles:
			return _path.back()
		_path.pop_back()
	var weighted_tiles: Dictionary = {}
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
