@tool
class_name UnitClass
extends Resource

enum MovementTypes {
	FOOT,
	ADVANCED_FOOT,
	FIGHTERS,
	ARMOR,
	BANDITS,
	PIRATES,
	BERSERKER,
	MAGES,
	LIGHT_CAVALRY,
	ADVANCED_LIGHT_CAVALRY,
	HEAVY_CAVALRY,
	ADVANCED_HEAVY_CAVALRY,
	FLIERS,
}

const MAX_START_STAT: int = 10
const MAX_END_STAT: int = 25
const MIN_HIT_POINTS: int = 20
const MAX_HIT_POINTS: int = 60

@warning_ignore("unused_private_class_variable")
var _base_hit_points: int
@warning_ignore("unused_private_class_variable")
var _base_strength: int
@warning_ignore("unused_private_class_variable")
var _base_pierce: int
@warning_ignore("unused_private_class_variable")
var _base_intelligence: int
@warning_ignore("unused_private_class_variable")
var _base_dexterity: int
@warning_ignore("unused_private_class_variable")
var _base_speed: int
@warning_ignore("unused_private_class_variable")
var _base_luck: int
@warning_ignore("unused_private_class_variable")
var _base_defense: int
@warning_ignore("unused_private_class_variable")
var _base_armor: int
@warning_ignore("unused_private_class_variable")
var _base_resistance: int
@warning_ignore("unused_private_class_variable")
var _base_movement: int
@warning_ignore("unused_private_class_variable")
var _base_build: int

var _weapon_levels: Dictionary[Weapon.Types, int]
var _max_level: int = 30
var _movement_type: MovementTypes  # Movement class for handling moving over terrain.
var _map_sprite: CompressedTexture2D
var _default_portrait: Texture2D
## Modifier applied to build when calculating aid.
## Negative values means aid = (con + _aid_modifier);
## positive values means aid = (_aid_modifier - con); zero means aid = con
var _aid_modifier: int = -1
var _weight_modifier: int = 0
var _description: String = "[Empty]"
var _authority: int
var _skills: Array[Skill] = [FollowUp.new(), Shove.new()]


func _init() -> void:
	var parent_folder: String = (get_script() as Script).resource_path.get_base_dir()
	_map_sprite = load("%s/map_sprite.png" % parent_folder)
	var portrait_dir: String = "%s/portrait.png" % parent_folder
	if FileAccess.file_exists(portrait_dir):
		_default_portrait = load(portrait_dir)


func get_stat(stat: Unit.Stats, level: int) -> float:
	# Can't use match as this technically isn't constant.
	if 1 << stat & Unit.get_fixed_stat_flags():
		return _get_base_stat(stat) as float
	else:
		var weight: float = inverse_lerp(1, Unit.LEVEL_CAP, level)
		match stat:
			Unit.Stats.HIT_POINTS:
				return clampf(
					_get_base_stat(stat) * lerpf(0.5, 1, weight), MIN_HIT_POINTS, MAX_HIT_POINTS
				)

			_:
				return clampf(
					_get_base_stat(stat) - lerpf(MAX_END_STAT - MAX_START_STAT, 0, weight),
					0,
					MAX_END_STAT
				)


func get_weapon_level(type: Weapon.Types) -> int:
	return _weapon_levels.get(type, 0)


func get_level_cap() -> int:
	return _max_level


func get_movement_type() -> MovementTypes:
	return _movement_type


func get_map_sprite() -> CompressedTexture2D:
	return _map_sprite


func get_default_portrait() -> Texture2D:
	return _default_portrait


func get_aid_modifier() -> int:
	return _aid_modifier


func get_weight_modifier() -> int:
	return _weight_modifier


func get_description() -> StringName:
	return _description


func get_authority() -> int:
	return _authority


func get_skills() -> Array[Skill]:
	return _skills


## Returns the colors used by the palette for palette swapping
func get_palette_basis() -> Array[Color]:
	return _get_blue_palette() + _get_default_blue_hair_palette()


func get_palette(color: Faction.Colors) -> Array[Color]:
	match color:
		Faction.Colors.BLUE:
			return _get_blue_palette()
		Faction.Colors.RED:
			return _get_red_palette()
		Faction.Colors.GREEN:
			return _get_green_palette()
		_:
			push_error("Color %s not found." % Faction.Colors.find_key(color))
			return _get_blue_palette()


func get_wait_palette() -> Array[Color]:
	return [
		Color("D8D8D8"),
		Color("808080"),
		Color("383838"),
		Color("B8B8B8"),
		Color("606060"),
		Color("383838"),
		Color("101818"),
		Color("909090"),
		Color("585858"),
		Color("080810"),
	]


func get_default_hair_palette(color: Faction.Colors) -> Array[Color]:
	match color:
		Faction.Colors.BLUE:
			return _get_default_blue_hair_palette()
		Faction.Colors.RED:
			return _get_default_red_hair_palette()
		Faction.Colors.GREEN:
			return _get_default_green_hair_palette()
		_:
			push_error("Color %s not found." % Faction.Colors.find_key(color))
			return _get_blue_palette()


func _get_base_stat(stat: Unit.Stats) -> int:
	return get("_base_%s" % (Unit.Stats.find_key(stat) as String).to_snake_case())


func _get_blue_palette() -> Array[Color]:
	return [
		Color("F8F8F8"),
		Color("A8A898"),
		Color("484840"),
		Color("B0D0F8"),
		Color("4048F8"),
		Color("101850"),
		Color("202028"),
		Color("D8B890"),
		Color("806048"),
		Color("081020"),
	]


func _get_red_palette() -> Array[Color]:
	return [
		Color("F8F8F8"),
		Color("989060"),
		Color("484830"),
		Color("E8B8B0"),
		Color("A83818"),
		Color("481018"),
		Color("282020"),
		Color("D8B890"),
		Color("886850"),
		Color("100000"),
	]


func _get_green_palette() -> Array[Color]:
	return [
		Color("F8F8F8"),
		Color("887038"),
		Color("503810"),
		Color("A8E0B8"),
		Color("389848"),
		Color("083010"),
		Color("202820"),
		Color("D8B890"),
		Color("886850"),
		Color("082010"),
	]


func _get_default_blue_hair_palette() -> Array[Color]:
	return [
		Color("D07030"),
		Color("783018"),
	]


func _get_default_red_hair_palette() -> Array[Color]:
	return [
		Color("8070D8"),
		Color("502098"),
	]


func _get_default_green_hair_palette() -> Array[Color]:
	return [
		Color("D03830"),
		Color("581000"),
	]


func _to_string() -> String:
	return 'UnitClass:"{name}"<#{id}>'.format({"name": resource_name, "id": get_instance_id()})
