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
var stat_caps: Dictionary
var weapon_levels: Dictionary
var max_level: int = 50
var movement_type: movement_types # Movement class for handling moving over terrain.
var map_sprite: CompressedTexture2D
var default_portrait: Texture2D
