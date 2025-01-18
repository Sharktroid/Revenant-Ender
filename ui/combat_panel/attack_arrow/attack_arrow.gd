class_name AttackArrow
extends HBoxContainer

## The direction the arrow is facing.
enum DIRECTIONS { LEFT, RIGHT }
## What event will occur
enum EVENTS { NONE, KILL, CRIT_KILL }

const _BLUE_COLORS: Array[Color] = [
	Color("5294D6"),
	Color("4279BD"),
	Color("31599C"),
]
const _RED_COLORS: Array[Color] = [
	Color("D65A63"),
	Color("BD4942"),
	Color("9C4131"),
]


static func instantiate(
	direction: DIRECTIONS, damage: float, crit_damage: float, event: EVENTS, color: Faction.Colors
) -> AttackArrow:
	var scene: AttackArrow = (
		preload("res://ui/combat_panel/attack_arrow/attack_arrow.tscn").instantiate()
	)
	var is_left: bool = direction == DIRECTIONS.LEFT
	var damage_label := scene.get_node("LeftDamage" if is_left else "RightDamage") as Label
	var format_dictionary: Dictionary = {
		"damage": Utilities.float_to_string(damage),
		"crit_damage": Utilities.float_to_string(crit_damage)
	}
	damage_label.text = "{damage} ({crit_damage})".format(format_dictionary)
	var symbol_rect := scene.get_node("LeftSymbol" if is_left else "RightSymbol") as TextureRect
	if event in [EVENTS.KILL, EVENTS.CRIT_KILL]:
		symbol_rect.texture = preload("res://ui/combat_panel/attack_arrow/kill.png")
		if event == EVENTS.CRIT_KILL:
			symbol_rect.modulate.a = 2.0/3
	var arrow := scene.get_node("%Arrow") as TextureRect
	arrow.flip_h = is_left
	if color != Faction.Colors.BLUE:
		var shader_material := arrow.material.duplicate(true) as ShaderMaterial
		shader_material.set_shader_parameter("old_colors", _BLUE_COLORS.duplicate())
		shader_material.set_shader_parameter("new_colors", _get_new_color(color).duplicate())
		arrow.material = shader_material
	return scene


static func _get_new_color(color: Faction.Colors) -> Array[Color]:
	match color:
		_:
			return _RED_COLORS
