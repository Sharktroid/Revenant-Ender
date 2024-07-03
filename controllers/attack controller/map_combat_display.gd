class_name MapCombatDisplay
extends HBoxContainer

const V_MOD: int = 32

var attacker: Unit
var defender: Unit


func _enter_tree() -> void:
	($LeftHPBar as MapHPBar).unit = attacker
	($RightHPBar as MapHPBar).unit = defender
	position = Vector2(
		(attacker.position.x + defender.position.x) / 2 - size.x / 2,
		maxf(attacker.position.y, defender.position.y)
	)
	position += (
		Vector2(MapController.get_map_camera().get_map_offset())
		- Vector2(MapController.get_map_camera().map_position)
		+ Vector2(8, V_MOD)
	)
	if position.y + size.y > Utilities.get_screen_size().y:
		position.y -= (size.y + V_MOD * 2)


static func instantiate(new_attacker: Unit, new_defender: Unit) -> MapCombatDisplay:
	const PACKED_SCENE: PackedScene = preload(
		"res://controllers/attack controller/map_combat_display.tscn"
	)
	var scene := PACKED_SCENE.instantiate() as MapCombatDisplay
	scene.attacker = new_attacker
	scene.defender = new_defender
	return scene
