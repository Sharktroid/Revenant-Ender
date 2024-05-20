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

const MAX_END_STAT: int = 30

var _base_hit_points: int
var _base_strength: int
var _base_pierce: int
var _base_intelligence: int
var _base_skill: int
var _base_speed: int
var _base_luck: int
var _base_defense: int
var _base_armor: int
var _base_resistance: int
var _base_movement: int
var _base_build: int

var _end_hit_points: int
var _end_strength: int
var _end_pierce: int
var _end_intelligence: int
var _end_skill: int
var _end_speed: int
var _end_luck: int
var _end_defense: int
var _end_armor: int
var _end_resistance: int
var _end_movement: int
var _end_build: int

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


func get_base_stat(stat: Unit.Stats) -> int:
	return get("_base_%s" % (Unit.Stats.find_key(stat) as String).to_snake_case())


func get_base_hit_points() -> int:
	return _base_hit_points


func get_base_strength() -> int:
	return _base_strength


func get_base_pierce() -> int:
	return _base_pierce


func get_base_intelligence() -> int:
	return _base_intelligence


func get_base_skill() -> int:
	return _base_skill


func get_base_speed() -> int:
	return _base_speed


func get_base_luck() -> int:
	return _base_luck


func get_base_defense() -> int:
	return _base_defense


func get_base_armor() -> int:
	return _base_armor


func get_base_resistance() -> int:
	return _base_resistance


func get_base_movement() -> int:
	return _base_movement


func get_base_build() -> int:
	return _base_build


func get_end_stat(stat: Unit.Stats) -> int:
	return mini(
		get("_end_%s" % (Unit.Stats.find_key(stat) as String).to_snake_case()) as int, MAX_END_STAT
	)


func get_end_hit_points() -> int:
	return _end_hit_points


func get_end_strength() -> int:
	return _end_strength


func get_end_pierce() -> int:
	return _end_pierce


func get_end_intelligence() -> int:
	return _end_intelligence


func get_end_skill() -> int:
	return _end_skill


func get_end_speed() -> int:
	return _end_speed


func get_end_luck() -> int:
	return _end_luck


func get_end_defense() -> int:
	return _end_defense


func get_end_armor() -> int:
	return _end_armor


func get_end_resistance() -> int:
	return _end_resistance


func get_end_movement() -> int:
	return _end_movement


func get_end_build() -> int:
	return _end_build


func get_stat(stat: Unit.Stats, level: int) -> float:
	return lerpf(get_base_stat(stat), get_end_stat(stat), inverse_lerp(1, Unit.LEVEL_CAP, level))


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
