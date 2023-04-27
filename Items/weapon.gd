class_name Weapon
extends "res://Items/base_item.gd"

enum types {
	SWORD,
	LANCE,
	AXE,
	BOW,
	KNIFE,
	WIND,
	FIRE,
	THUNDER,
	LIGHT,
	DARK,
	CRIMSON_STAFF,
	COBALT_STAFF,
}
enum ranks {S = 251,
	A = 181,
	B = 121,
	C = 71,
	D = 31,
	E = 1,
	DISABLED = 0
}

var level: int
var might: int
var weight: int
var hit: int
var crit: int
var min_range: int
var max_range: int
var max_durability: int
var current_durability: int
var price: int
var weapon_experience: int
var effective_classes: int
var type: int
