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

var _base_stats: Dictionary
var _end_stats: Dictionary
var _base_weapon_levels: Dictionary
var _max_weapon_levels: Dictionary
var _max_level: int = 30
var _movement_type: MovementTypes  # Movement class for handling moving over terrain.
var _map_sprite: CompressedTexture2D
var _default_portrait: Texture2D
## Modifier applied to constitution when calculating aid.
## Negative values means aid = (con + _aid_modifier);
## positive values means aid = (_aid_modifier - con); zero means aid = con
var _aid_modifier: int = -1
var _weight_modifier: int = 0
var _description: String = "[Empty]"
var _authority: int
var _skills: Array[Skill]


func _init() -> void:
	var parent_folder: String = (get_script() as Script).resource_path.get_base_dir()
	_map_sprite = load("%s/map_sprite.png" % parent_folder)
	var portrait_dir: String = "%s/portrait.png" % parent_folder
	if FileAccess.file_exists(portrait_dir):
		_default_portrait = load(portrait_dir)


func get_base_stats() -> Dictionary:
	return _base_stats


func get_end_stats() -> Dictionary:
	return _end_stats


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
