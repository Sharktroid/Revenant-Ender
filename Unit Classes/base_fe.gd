@tool
class_name FEUnit
extends "res://Unit Classes/unit_base.gd"

enum items_enum {RAPIER, IRON_LANCE, IRON_AXE, IRON_BOW}
enum stats {
	HITPOINTS, STRENGTH, PIERCE, MAGIC, SKILL, SPEED, LUCK, DEFENSE, DURABILITY,
	RESISTANCE, MOVEMENT, CONSTITUTION, LEADERSHIP
}

@export var init_items: Array[items_enum] # No way to load weapons directly via export variable.
@export var current_level: int = 1
@export var personal_stat_caps: Dictionary
@export var personal_end_stats: Dictionary
@export var personal_base_stats: Dictionary

var items: Array[Item]
var weapon_levels: Dictionary
var attack: int

var _max_level: int = 50
var _class_base_stats: Dictionary
var _class_end_stats: Dictionary
var _class_stat_caps: Dictionary
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


func _enter_tree() -> void:
	for weapon in Weapon.types:
		weapon_levels[weapon] = 0
	for stat in len(stats):
		if not(stat in personal_base_stats):
			personal_base_stats[stat] = 0
		if not(stat in personal_end_stats):
			personal_end_stats[stat] = 0
		if not(stat in personal_stat_caps):
			personal_stat_caps[stat] = 0
		if not(stat in _stat_boosts):
			_stat_boosts[stat] = 0


func _ready() -> void:
	material = material.duplicate()
	current_movement = get_movement()
	for item in init_items:
		match item:
			items_enum.RAPIER: items.append(Rapier.new())
			items_enum.IRON_LANCE: items.append(Iron_Lance.new())
			items_enum.IRON_AXE: items.append(Iron_Axe.new())
			items_enum.IRON_BOW: items.append(Iron_Bow.new())
	_update_palette()
	if len(items) > 0:
		max_range = items[0].max_range
		min_range = items[0].min_range
	attack = get_stat(stats.STRENGTH)
	if len(items) > 0:
		attack += items[0].might
	super()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		print_debug((material as ShaderMaterial).get_shader_parameter("conversion_array"))


func wait() -> void:
	super()
	_update_palette()


func awaken() -> void:
	super()
	_update_palette()


func get_damage(defender: Unit) -> float:
	return max(0, attack - defender.get_current_defence((items[0] as Weapon).get_damage_type()))


func get_current_defence(attacker_weapon_type: Weapon.damage_types) -> int:
	match attacker_weapon_type:
		Weapon.damage_types.RANGED: return get_stat(stats.DURABILITY)
		Weapon.damage_types.MAGIC: return get_stat(stats.RESISTANCE)
		Weapon.damage_types.PHYSICAL: return get_stat(stats.DEFENSE)
		_:
			push_error("Damage Type %s Invalid" % attacker_weapon_type)
			return 0


func reset_map_anim() -> void:
	frame_coords.x = 0


func get_stat_boost(stat: stats) -> int:
	return _stat_boosts[stat]


func get_stat(stat: stats, level: int = current_level) -> int:
	var base_stat: int = _class_base_stats[stat] + personal_base_stats[stat]
	var end_stat: int = _class_end_stats[stat] + personal_end_stats[stat]
	var leveled_stats: int = end_stat - base_stat
	var leveled_stat_boost: int = (leveled_stats * (level as float)/_max_level) as int
	var max_stat: int = _class_stat_caps[stat] + personal_stat_caps[stat]
	return clamp(base_stat + leveled_stat_boost + get_stat_boost(stat), 0, max_stat)


func get_movement() -> int:
	return get_stat(stats.MOVEMENT)


func _update_palette() -> void:
	if GenVars.get_map():
		_set_palette(get_faction().color)


func _animate_sprite() -> void:
	super()
	if map_animation == animations.IDLE:
		var frame_num: int = int(GenVars.get_tick_timer()) % 64
		if (frame_num >= 16 and frame_num < 32) or frame_num >= 48:
			frame = 1
		elif frame_num >= 32 and frame_num < 48:
			frame = 2
		else:
			frame = 0
	else:
		match map_animation:
			animations.MOVING_RIGHT, animations.MOVING_LEFT: frame_coords.y = 1
			animations.MOVING_DOWN: frame_coords.y = 2
			animations.MOVING_UP: frame_coords.y = 3
		var frame_num: float = 10
		var frame_count: float = fmod(GenVars.get_tick_timer(), (frame_num * 4))
		if frame_count >= frame_num and frame_count < (frame_num * 2):
			frame_coords.x = 1
		elif frame_count >= (frame_num * 2) and frame_count < (frame_num * 3):
			frame_coords.x = 2
		elif frame_count >= (frame_num * 3):
			frame_coords.x = 3
		else:
			frame_coords.x = 0
	if map_animation == animations.MOVING_LEFT:
		flip_h = true
	else:
		flip_h = false


func _set_palette(color: Faction.colors) -> void:
	var palette: Array[Array]
	match waiting:
		true: palette = _wait_palette
		false:
			match color:
				Faction.colors.RED: palette = _red_palette
				Faction.colors.GREEN : palette = _green_palette
				Faction.colors.BLUE: palette = _default_palette
				Faction.colors.PURPLE: palette = _purple_palette
				var invalid:
					palette = _default_palette
					push_error("Color %s does not have a palette." % invalid)
	var old_colors: Array[Vector3] = []
	var new_colors: Array[Vector3] = []
	for color_set in palette:
		old_colors.append(color_set[0])
		new_colors.append(color_set[1])
	(material as ShaderMaterial).set_shader_parameter("old_colors", old_colors)
	(material as ShaderMaterial).set_shader_parameter("new_colors", new_colors)


func _set_base_frame() -> void:
	pass
