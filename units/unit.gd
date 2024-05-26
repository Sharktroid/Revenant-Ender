# gdlint:ignore = max-public-methods
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
	INTELLIGENCE,
	SKILL,
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
## The added amount when the stat is 0 and PVs are maxed
const PERSONAL_VALUE_MIN_MODIFIER: float = 2.5
## The added amount when hit points are 0 and PVs are maxed
const PERSONAL_VALUE_MIN_HIT_POINTS_MODIFIER: float = 5
## The added amount when the stat is the unit class max and PVs are maxed
const PERSONAL_VALUE_MAX_MODIFIER: float = 5
## The added amount when hit points are the unit class max and PVs are maxed
const PERSONAL_VALUE_MAX_HIT_POINTS_MODIFIER: float = 10
## The added amount when the stat is 0 and EVs are maxed
const EFFORT_VALUE_MIN_MODIFIER: float = 2.5
## The added amount when the stat is 0 and EVs are maxed
const EFFORT_VALUE_MIN_HIT_POINTS_MODIFIER: float = 5
## The added amount when hit points are the unit class max and EVs are maxed
const EFFORT_VALUE_MAX_MODIFIER: float = 5
## The added amount when hit points are the unit class max and EVs are maxed
const EFFORT_VALUE_MAX_HIT_POINTS_MODIFIER: float = 10
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
const EXP_MULTIPLIER: float = 2 ** (1.0 / 3)
## The amount of experience for killing an enemy in one round of combat
const ONE_ROUND_EXP_BASE: float = float(BASE_EXP) / 3
## The amount of combat experience reserved for when an enemy is killed
const KILL_EXP_PERCENT: float = 0.25
const DEFAULT_PERSONAL_VALUE: int = 5
const MAX_LEVEL: int = 30
const _MOVEMENT_ARROWS: PackedScene = preload("res://maps/map_tiles/movement_arrows.tscn")

## Unit's faction. Should be in the map's Faction stack.
@export var unit_name: String = "[Empty]"
@export_multiline var unit_description: String = "[Empty]"
@export var unit_class: UnitClass
@export var faction_id: int
@export var variant: String  # Visual variant.
@export var items: Array[Item]
@export var base_level: int = 1
@export var personal_skills: Array[Skill]

var total_exp: float
var level: int:
	set(value):
		total_exp = Unit.get_exp_from_level(value)
	get:
		return floori(Unit.get_level_from_exp(total_exp))
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
		current_health = clampf(health, 0, get_hit_points())
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

var effort_hit_points: int
var effort_strength: int
var effort_pierce: int
var effort_intelligence: int
var effort_skill: int
var effort_speed: int
var effort_luck: int
var effort_defense: int
var effort_armor: int
var effort_resistance: int
var effort_movement: int
var effort_build: int

@warning_ignore("unused_private_class_variable")
var _personal_hit_points: int = 5
@warning_ignore("unused_private_class_variable")
var _personal_strength: int = 5
@warning_ignore("unused_private_class_variable")
var _personal_pierce: int = 5
@warning_ignore("unused_private_class_variable")
var _personal_intelligence: int = 5
@warning_ignore("unused_private_class_variable")
var _personal_skill: int = 5
@warning_ignore("unused_private_class_variable")
var _personal_speed: int = 5
@warning_ignore("unused_private_class_variable")
var _personal_luck: int = 5
@warning_ignore("unused_private_class_variable")
var _personal_defense: int = 5
@warning_ignore("unused_private_class_variable")
var _personal_armor: int = 5
@warning_ignore("unused_private_class_variable")
var _personal_resistance: int = 5
@warning_ignore("unused_private_class_variable")
var _personal_movement: int
@warning_ignore("unused_private_class_variable")
var _personal_build: int = 5

var _attack_tiles: Array[Vector2i]
var _movement_tiles: Array[Vector2i]
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
	_traveler_animation_player = $TravelerIcon/AnimationPlayer as AnimationPlayer
	level = base_level
	for weapon_type: Weapon.Types in (
		unit_class.get_base_weapon_levels().keys() as Array[Weapon.Types]
	):
		if weapon_type not in weapon_levels.keys():
			weapon_levels[weapon_type] = lerpf(
				unit_class.get_base_weapon_levels()[weapon_type] as float,
				unit_class.get_max_weapon_levels()[weapon_type] as float,
				inverse_lerp(1, unit_class.get_max_level(), level)
			)
	texture = unit_class.get_map_sprite()
	material = material.duplicate() as Material
	current_movement = get_movement()
	current_health = get_hit_points()
	add_to_group("units")
	_update_palette()
	if _animation_player.current_animation == "":
		_animation_player.play("idle")
	Utilities.sync_animation(_animation_player)
	var directory: String = "res://portraits/{name}/{name}.tscn".format(
		{"name": unit_name.to_snake_case()}
	)
	if FileAccess.file_exists(directory):
		_portrait = (load(directory) as PackedScene).instantiate() as Portrait


func _exit_tree() -> void:
	get_map().update_position_terrain_cost.call_deferred(position)


func _process(_delta: float) -> void:
	update_shader()
	if traveler:
		traveler.position = position
	_render_status()
	if _animation_player.current_animation == "idle":
		var anim_frame: int = floori((Engine.get_physics_frames() as float) / 16) % 4
		frame = 1 if anim_frame == 3 else anim_frame
	z_index = Utilities.round_coords_to_tile(position).y
	update_shader()


func update_shader() -> void:
	(material as ShaderMaterial).set_shader_parameter("modulate", modulate)


func has_status(status: int) -> bool:
	return status in _current_statuses


func add_status(status: int) -> void:
	_current_statuses.append(status)


func remove_status(status: int) -> void:
	_current_statuses.erase(status)


func get_class_name() -> String:
	return unit_class.resource_name


func get_current_weapon() -> Weapon:
	for item: Item in items:
		if item is Weapon and can_use_weapon(item as Weapon):
			return item as Weapon
	return null


func get_current_attack() -> int:
	if get_current_weapon():
		match get_current_weapon().get_damage_type():
			Weapon.DamageTypes.PHYSICAL:
				return get_strength()
			Weapon.DamageTypes.RANGED:
				return get_pierce()
			Weapon.DamageTypes.INTELLIGENCE:
				return get_intelligence()
	return 0


## Attack without weapon triangle bonuses
func get_raw_attack() -> int:
	return (get_current_weapon().get_might() if get_current_weapon() else 0) + get_current_attack()


func get_true_attack(enemy: Unit) -> int:
	if get_current_weapon():
		return (
			get_raw_attack()
			+ get_current_weapon().get_damage_bonus(enemy.get_current_weapon(), get_distance(enemy))
		)
	return 0


func get_damage(defender: Unit) -> int:
	return maxi(0, get_true_attack(defender) - defender.get_current_defence(get_current_weapon()))


func get_crit_damage(defender: Unit) -> int:
	return maxi(
		0, get_true_attack(defender) * 2 - defender.get_current_defence(get_current_weapon())
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
	var leveled_stat: float = unit_class.get_stat(stat, current_level)
	var unclamped_stat: int = roundi(
		leveled_stat
		+ _get_personal_modifier(stat, current_level)
		+ _get_effort_modifier(stat, current_level)
	)
	return clampi(unclamped_stat, 0, get_stat_cap(stat)) + get_stat_boost(stat)


func get_hit_points(current_level: int = level) -> int:
	return get_stat(Stats.HIT_POINTS, current_level)


func get_strength(current_level: int = level) -> int:
	return get_stat(Stats.STRENGTH, current_level)


func get_pierce(current_level: int = level) -> int:
	return get_stat(Stats.PIERCE, current_level)


func get_intelligence(current_level: int = level) -> int:
	return get_stat(Stats.INTELLIGENCE, current_level)


func get_skill(current_level: int = level) -> int:
	return get_stat(Stats.SKILL, current_level)


func get_speed(current_level: int = level) -> int:
	return get_stat(Stats.SPEED, current_level)


func get_luck(current_level: int = level) -> int:
	return get_stat(Stats.LUCK, current_level)


func get_defense(current_level: int = level) -> int:
	return get_stat(Stats.DEFENSE, current_level)


func get_armor(current_level: int = level) -> int:
	return get_stat(Stats.ARMOR, current_level)


func get_resistance(current_level: int = level) -> int:
	return get_stat(Stats.RESISTANCE, current_level)


func get_build(current_level: int = level) -> int:
	return get_stat(Stats.BUILD, current_level)


func get_movement(current_level: int = level) -> int:
	return get_stat(Stats.MOVEMENT, current_level)


func get_stat_cap(stat: Stats) -> int:
	var is_hit_points: int = stat == Stats.HIT_POINTS
	return roundi(
		(unit_class.get_end_stat(stat))
		+ (PERSONAL_VALUE_MAX_HIT_POINTS_MODIFIER if is_hit_points else PERSONAL_VALUE_MAX_MODIFIER)
		+ (EFFORT_VALUE_MAX_HIT_POINTS_MODIFIER if is_hit_points else EFFORT_VALUE_MAX_MODIFIER)
	)


func get_weapon_effective_weight() -> int:
	return maxi(get_current_weapon().get_weight() - get_build(), 0) if get_current_weapon() else 0


func get_attack_speed() -> int:
	return get_speed() - get_weapon_effective_weight()


func get_current_defence(weapon: Weapon) -> int:
	match weapon.get_damage_type():
		Weapon.DamageTypes.PHYSICAL:
			return get_defense()
		Weapon.DamageTypes.RANGED:
			return get_armor()
		Weapon.DamageTypes.INTELLIGENCE:
			return get_resistance()
		var damage_type:
			push_error("Damage Type %s Invalid" % damage_type)
			return 0


func get_area() -> Area2D:
	return $Area2D as Area2D


func get_portrait() -> Portrait:
	if _portrait:
		return _portrait.duplicate() as Portrait
	var portrait := Portrait.new()
	portrait.texture = unit_class.get_default_portrait()
	portrait.centered = false
	portrait.material = ShaderMaterial.new()
	(portrait.material as ShaderMaterial).shader = preload("res://gba_color.gdshader")
	return portrait


func get_portrait_offset() -> Vector2i:
	return Vector2i(-8, 0) if _portrait else Vector2i()


func get_aid() -> int:
	var aid_mod: int = unit_class.get_aid_modifier()
	return get_build() + aid_mod if aid_mod <= 0 else aid_mod - get_build()


func get_weight() -> int:
	return get_build() + unit_class.get_weight_modifier()


func get_hit() -> int:
	return get_current_weapon().get_hit() + get_skill() * 2 + get_luck()


func get_avoid() -> int:
	return get_attack_speed() * 2 + get_luck()


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
	return get_current_weapon().get_crit() + get_skill()


func get_crit_avoid() -> int:
	return get_luck()


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
		"Class Base": str(unit_class.get_base_stat(stat)),
		"Class Final": str(unit_class.get_end_stat(stat)),
		"Personal Value": str(get_personal_value(stat)),
		"Effort Value": str(get_effort_value(stat)),
	}
	return Utilities.dict_to_table(table_items)


func get_min_range() -> int:
	var min_range: int = get_current_weapon().get_min_range()
	for weapon: Item in items:
		if weapon is Weapon:
			min_range = mini((weapon as Weapon).get_min_range(), min_range)
	return min_range


func get_max_range() -> int:
	var max_range: int = get_current_weapon().get_max_range()
	for weapon: Item in items:
		if weapon is Weapon:
			max_range = maxi((weapon as Weapon).get_max_range(), max_range)
	return max_range


func get_authority() -> int:
	return personal_authority + unit_class.get_authority()


func get_distance(unit: Unit) -> int:
	return roundi(Utilities.get_tile_distance(position, unit.position))


func get_skills() -> Array[Skill]:
	return personal_skills + unit_class.get_skills()


func get_current_exp() -> float:
	return total_exp - Unit.get_exp_from_level(level)


static func get_exp_from_level(current_level: float) -> float:
	return BASE_EXP * ((EXP_MULTIPLIER ** (current_level - 1)) - 1) / (EXP_MULTIPLIER - 1)


static func get_level_from_exp(xp: float) -> float:
	return log(float(xp) * (EXP_MULTIPLIER - 1) / BASE_EXP + 1) / log(EXP_MULTIPLIER) + 1


static func get_exp_to_level(current_level: float) -> float:
	return get_exp_from_level(current_level) - get_exp_from_level(current_level - 1)


func get_exp_percent() -> int:
	return floori((roundf(get_current_exp()) / Unit.get_exp_to_level(level + 1)) * 100)


func get_personal_value(stat: Stats) -> int:
	return get("_personal_%s" % (Unit.Stats.find_key(stat) as String).to_snake_case())


func get_effort_value(stat: Stats) -> int:
	return get("effort_%s" % (Unit.Stats.find_key(stat) as String).to_snake_case())


func can_use_weapon(weapon: Weapon) -> bool:
	return weapon.get_rank() <= weapon_levels.get(weapon.get_type(), 0)


func can_rescue(unit: Unit) -> bool:
	return unit.get_weight() < get_aid() and is_friend(unit) and not traveler


## Causes unit to wait.
func wait() -> void:
	current_movement = get_movement()
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
	if CursorController.get_hovered_unit() == self:
		update_displayed_tiles()
	else:
		hide_movement_tiles()


## Un-waits unit.
func awaken() -> void:
	current_movement = get_movement()
	selectable = true
	waiting = false
	_update_palette()


func get_movement_tiles() -> Array[Vector2i]:
	# Gets the movement tiles of the unit
	if _movement_tiles.is_empty():
		var start: Vector2i = position
		const RANGE_MULT: float = 4.0 / 3
		var movement_tiles_dict: Dictionary = {floori(current_movement) as float: [start]}
		if position == ((position / 16).floor() * 16):
			#region Gets the initial grid
			var h: Array[Vector2i] = Utilities.get_tiles(
				start, ceili(current_movement * RANGE_MULT), 0, MapController.map.borders
			)
			#endregion
			#region Orders tiles by distance from center
			h.erase(start)
			for x: Vector2i in h:
				var movement_type: UnitClass.MovementTypes = unit_class.get_movement_type()
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
				_movement_tiles.append_array(converted)
	return _movement_tiles


func get_all_attack_tiles() -> Array[Vector2i]:
	if _attack_tiles.is_empty() and get_current_weapon():
		var basis_movement_tiles := get_movement_tiles().duplicate() as Array[Vector2i]
		for unit: Unit in get_map().get_units():
			if unit != self:
				var unit_pos: Vector2i = unit.position
				if unit_pos in basis_movement_tiles:
					basis_movement_tiles.erase(unit_pos)
		var min_range: int = get_min_range()
		var max_range: int = get_max_range()
		for tile: Vector2i in basis_movement_tiles:
			var subtiles: Dictionary = {}
			for subtile: Vector2i in Utilities.get_tiles(tile, min_range, 1):
				subtiles[subtile] = subtile in get_movement_tiles()
			if subtiles.values().any(func(value: bool) -> bool: return not value):
				var current_tiles: Array[Vector2i] = _attack_tiles + get_movement_tiles()
				for attack_tile: Vector2i in Utilities.get_tiles(
					tile, max_range, min_range, MapController.map.borders
				):
					if not attack_tile in current_tiles:
						_attack_tiles.append(attack_tile)
	return _attack_tiles


## Displays the unit's movement tiles.
func display_movement_tiles() -> void:
	hide_movement_tiles()
	var movement_tiles: Array[Vector2i] = get_movement_tiles()
	_movement_tiles_node = get_map().display_tiles(movement_tiles, Map.TileTypes.MOVEMENT, 1)
	_attack_tile_node = get_map().display_tiles(get_all_attack_tiles(), Map.TileTypes.ATTACK, 1)
	if not selected:
		_movement_tiles_node.modulate.a = 0.5
		_attack_tile_node.modulate.a = 0.5


## Hides the unit's movement tiles.
func hide_movement_tiles() -> void:
	if is_instance_valid(_movement_tiles_node):
		_movement_tiles_node.queue_free()
		_attack_tile_node.queue_free()


func get_current_attack_tiles(pos: Vector2i, all_weapons: bool = false) -> Array[Vector2i]:
	if is_instance_valid(get_current_weapon()):
		var min_range: int = (
			get_min_range() if all_weapons else get_current_weapon().get_min_range()
		)
		var max_range: int = (
			get_max_range() if all_weapons else get_current_weapon().get_max_range()
		)
		return Utilities.get_tiles(pos, max_range, min_range, MapController.map.borders)
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
func update_displayed_tiles() -> void:
	if is_instance_valid(_movement_tiles_node):
		match selected:
			true:
				_movement_tiles_node.modulate.a = 1
				_attack_tile_node.modulate.a = 1
			false:
				_movement_tiles_node.modulate.a = .5
				_attack_tile_node.modulate.a = .5


## Adds skill to this unit's personal_skills.
func add_skill(skill: Skill) -> void:
	personal_skills.append(skill)


## Moves unit to "move_target"
func move(move_target: Vector2i = get_unit_path()[-1]) -> void:
	hide_movement_tiles()
	update_path(move_target)
	var path: Array[Vector2i] = get_unit_path()
	if move_target in path:
		remove_path()
		get_area().monitoring = false
		current_movement -= get_map().get_path_cost(unit_class.get_movement_type(), path)
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
		return MapController.map
	return _map


## Gets the path of the unit.
func update_path(destination: Vector2i) -> void:
	if _path.size() == 0:
		_path.append(Vector2i(position))
	# Sets destination to an adjacent tile to a unit if a unit is hovered and over an attack tile.
	var movement_tiles: Array[Vector2i] = get_movement_tiles()
	var all_attack_tiles: Array[Vector2i] = get_all_attack_tiles()
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
				for tile_offset: Vector2i in Utilities.ADJACENT_TILES:
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
				total_cost += get_map().get_terrain_cost(unit_class.get_movement_type(), tile)
		if destination in _path:
			_path = _path.slice(0, _path.find(destination) + 1) as Array[Vector2i]
		else:
			if (
				total_cost <= current_movement
				and destination - get_unit_path()[-1] in Utilities.ADJACENT_TILES
			):
				_path.append(destination)
			else:
				var new_path: Array[Vector2i] = get_map().get_movement_path(
					unit_class.get_movement_type(), position, destination, faction
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
		push_error(
			'Tried equipping invalid weapon "%s" on unit "%s"' % [weapon.resource_name, unit_name]
		)


func drop(item: Item) -> void:
	items.erase(item)
	hide_movement_tiles()
	display_movement_tiles()


func reset_tile_cache() -> void:
	_movement_tiles = []
	_attack_tiles = []


func can_follow_up(opponent: Unit) -> bool:
	return get_skills().filter(func(skill: Skill) -> bool: return skill is FollowUp).any(
		func(skill: FollowUp) -> bool: return skill.can_follow_up(self, opponent)
	)


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
	for color_set: Array[Vector3] in palette:
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
		if is_instance_valid(CursorController.get_hovered_unit()):
			can_be_selected = not CursorController.get_hovered_unit().selected or selecting
		if can_be_selected and not (selected or selecting or waiting or dead):
			display_movement_tiles()


func _get_personal_modifier(stat: Stats, current_level: int) -> float:
	var personal_value: float = clampf(get_personal_value(stat) as int, 0, PERSONAL_VALUE_LIMIT)
	var is_hit_points: bool = stat == Stats.HIT_POINTS
	return _get_value_modifier(
		stat,
		current_level,
		PERSONAL_VALUE_MIN_HIT_POINTS_MODIFIER if is_hit_points else PERSONAL_VALUE_MIN_MODIFIER,
		PERSONAL_VALUE_MAX_HIT_POINTS_MODIFIER if is_hit_points else PERSONAL_VALUE_MAX_MODIFIER,
		personal_value / PERSONAL_VALUE_LIMIT
	)


func _get_effort_modifier(stat: Stats, current_level: int) -> float:
	var effort_value: float = clampf(
		get_effort_value(stat) as int, 0, INDIVIDUAL_EFFORT_VALUE_LIMIT
	)
	var is_hit_points: bool = stat == Stats.HIT_POINTS
	return _get_value_modifier(
		stat,
		current_level,
		EFFORT_VALUE_MIN_HIT_POINTS_MODIFIER if is_hit_points else EFFORT_VALUE_MIN_MODIFIER,
		EFFORT_VALUE_MAX_HIT_POINTS_MODIFIER if is_hit_points else EFFORT_VALUE_MAX_MODIFIER,
		effort_value / INDIVIDUAL_EFFORT_VALUE_LIMIT
	)


func _get_value_modifier(
	stat: Stats, current_level: int, min_value: float, max_value: float, value_weight: float
) -> float:
	return (
		remap(
			unit_class.get_stat(stat, current_level),
			UnitClass.MIN_HIT_POINTS if stat == Stats.HIT_POINTS else 0,
			UnitClass.MAX_HIT_POINTS if stat == Stats.HIT_POINTS else UnitClass.MAX_END_STAT,
			min_value,
			max_value
		)
		* value_weight
	)


func _on_area2d_area_exited(area: Area2D) -> void:
	# When cursor exits unit's area
	if area == CursorController.get_area() and not selected:
		hide_movement_tiles()
		# gdlint:ignore = max-file-lines
		cursor_exited.emit()
