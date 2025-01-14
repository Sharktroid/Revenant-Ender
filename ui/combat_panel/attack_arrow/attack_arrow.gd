class_name AttackArrow
extends HBoxContainer

enum DIRECTIONS { LEFT, RIGHT }
enum EVENTS {NONE, KILL}


static func instantiate(direction: DIRECTIONS, damage: int, event: EVENTS) -> AttackArrow:
	var scene: AttackArrow = (
		preload("res://ui/combat_panel/attack_arrow/attack_arrow.tscn").instantiate()
	)
	var is_left: bool = direction == DIRECTIONS.LEFT
	(scene.get_node("LeftDamage" if is_left else "RightDamage") as Label).text = var_to_str(damage)
	var symbol_rect := scene.get_node("LeftSymbol" if is_left else "RightSymbol") as TextureRect
	if event == EVENTS.KILL:
		symbol_rect.texture = preload("res://ui/combat_panel/attack_arrow/kill.png")
	scene.get_node("%Arrow")
	return scene
