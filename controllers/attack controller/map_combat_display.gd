## Scene that displays the health of two [Unit]s during a round of combat on the map.
class_name MapCombatDisplay
extends HBoxContainer

const _V_MOD: int = 32

var _attacker: Unit
var _defender: Unit


func _enter_tree() -> void:
	($LeftHPBar as MapHPBar).unit = _attacker
	($RightHPBar as MapHPBar).unit = _defender
	var unit_midpoint := Vector2(
		(_attacker.position.x + _defender.position.x) / 2 - size.x / 2,
		maxf(_attacker.position.y, _defender.position.y)
	)
	var offset: Vector2i = (
		Vector2i(8, _V_MOD)
		- MapController.get_map_camera().get_map_offset()
		- MapController.get_map_camera().get_map_position()
	)
	position = unit_midpoint + Vector2(offset)
	if position.y + size.y > Utilities.get_screen_size().y:
		position.y -= (size.y + _V_MOD * 2)


## Instantiates the [PackedScene].
static func instantiate(attacker: Unit, defender: Unit) -> MapCombatDisplay:
	const PACKED_SCENE: PackedScene = preload(
		"res://controllers/attack controller/map_combat_display.tscn"
	)
	var scene := PACKED_SCENE.instantiate() as MapCombatDisplay
	scene._attacker = attacker
	scene._defender = defender
	return scene
