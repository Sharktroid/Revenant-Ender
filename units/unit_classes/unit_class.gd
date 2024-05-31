# gdlint:ignore = max-public-methods
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
const MAX_END_STAT: int = 30
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
var _base_skill: int
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

var _base_weapon_levels: Dictionary
var _max_weapon_levels: Dictionary
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
var _skills: Array[Skill] = [FollowUp.new()]


func _init() -> void:
	var parent_folder: String = (get_script() as Script).resource_path.get_base_dir()
	_map_sprite = load("%s/map_sprite.png" % parent_folder)
	var portrait_dir: String = "%s/portrait.png" % parent_folder
	if FileAccess.file_exists(portrait_dir):
		_default_portrait = load(portrait_dir)


func get_stat(stat: Unit.Stats, level: int) -> float:
	var weight: float = inverse_lerp(1, Unit.LEVEL_CAP, level)
	match stat:
		Unit.Stats.HIT_POINTS:
			return clampf(
				_get_base_stat(stat) * lerpf(0.5, 1, weight), MIN_HIT_POINTS, MAX_HIT_POINTS
			)

		Unit.Stats.MOVEMENT, Unit.Stats.BUILD:
			return _get_base_stat(stat) as float

		_:
			return clampf(
				_get_base_stat(stat) - lerpf(MAX_END_STAT - MAX_START_STAT, 0, weight),
				0,
				MAX_END_STAT
			)


func get_base_weapon_levels() -> Dictionary:
	return _base_weapon_levels


func get_max_weapon_levels() -> Dictionary:
	return _max_weapon_levels


func get_max_level() -> int:
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
	return _get_blue_palette()


func get_palette(color: Faction.Colors) -> Array[Color]:
	match color:
		Faction.Colors.BLUE:
			return _get_blue_palette()
		Faction.Colors.RED:
			return _get_red_palette()
		_:
			push_error("Color %s not found." % Faction.Colors.find_key(color))
			return _get_blue_palette()


func get_wait_palette() -> Array[Color]:
	const WAIT_PALETTE: Array[Color] = [
		Color("404040"),
		Color("787878"),
		Color("B8B8B8"),
		Color("505050"),
		Color("808080"),
		Color("C8C8C8"),
		Color("484848"),
		Color("585858"),
		Color("989898"),
		Color("B8B8B8"),
		Color("707070"),
		Color("707070"),
		Color("808870"),
		Color("D0D0D0"),
		Color("403838"),
	]
	return WAIT_PALETTE.duplicate()


func _get_base_stat(stat: Unit.Stats) -> int:
	return get("_base_%s" % (Unit.Stats.find_key(stat) as String).to_snake_case())


func _get_blue_palette() -> Array[Color]:
	const BLUE_PALETTE: Array[Color] = [
		Color("584878"),
		Color("90B8E8"),
		Color("D8E8F0"),
		Color("706060"),
		Color("B09058"),
		Color("F8F8D0"),
		Color("383890"),
		Color("3850E0"),
		Color("28A0F8"),
		Color("18F0F8"),
		Color("E81018"),
		Color("F8F840"),
		Color("808870"),
		Color("F8F8F8"),
		Color("403838"),
	]
	return BLUE_PALETTE.duplicate()


func _get_red_palette() -> Array[Color]:
	const RED_PALETTE: Array[Color] = [
		Color("684860"),
		Color("C0A8B8"),
		Color("C0A8B8"),
		Color("706060"),
		Color("B09058"),
		Color("F8F8D0"),
		Color("602820"),
		Color("A83028"),
		Color("E01010"),
		Color("F85048"),
		Color("38D030"),
		Color("F8F840"),
		Color("808870"),
		Color("F8F8F8"),
		Color("403838"),
	]
	return RED_PALETTE.duplicate()
