@tool
extends EditorScript

var old_class: UnitClass = SocialKnight.new()
var new_class: UnitClass = Cavalier.new()
var old_unit: Unit
var new_unit: Unit


func _run() -> void:
	old_unit = Unit.new()
	old_unit.unit_class = old_class
	new_unit = Unit.new()
	new_unit.unit_class = new_class
	print(_gets_stats(10))
	print(_gets_stats(20))


func _gets_stats(level: int) -> Array[int]:
	var output: Array[int] = []
	for stat: Unit.Stats in Unit.Stats.values():
		output.append(new_unit.get_stat(stat, level) - old_unit.get_stat(stat, level))
	return output
