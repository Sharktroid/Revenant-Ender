@tool
class_name UnitClass
extends Resource

enum movement_types {
	FOOT, ADVANCED_FOOT, FIGHTERS, ARMOR, BANDITS, PIRATES, BERSERKER, MAGES,
	LIGHT_CAVALRY, ADVANCED_LIGHT_CAVALRY, HEAVY_CAVALRY, ADVANCED_HEAVY_CAVALRY,
	FLIERS
}

var name: String
var base_stats: Dictionary
var end_stats: Dictionary
var base_weapon_levels: Dictionary
var max_weapon_levels: Dictionary
var max_level: int = 30
var movement_type: movement_types # Movement class for handling moving over terrain.
var map_sprite: CompressedTexture2D
var default_portrait: Texture2D
## Modifier applied to constitution when calculating aid.
## Negative values means aid = (con + aid_modifier);
## positive values means aid = (aid_modifier - con); zero means aid = con
var aid_modifier: int = -1
var weight_modifier: int = 0
var description: String = "[Empty]"
var authority: int
var skills: Array[Skill]

func _init() -> void:
	var parent_folder: String = (get_script() as Script).resource_path.get_base_dir()
	map_sprite = load("%s/map_sprite.png" % parent_folder)
	var portrait_dir: String = "%s/portrait.png" % parent_folder
	if FileAccess.file_exists(portrait_dir):
		default_portrait = load(portrait_dir)
