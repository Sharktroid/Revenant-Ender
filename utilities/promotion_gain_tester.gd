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
	var max_length: int = ((Unit.Stats.keys().reduce(_get_greater_string) as String).length()) + 1
	var base_string: String = "%-{length}s %3d %3d".format({"length": max_length})
	print(base_string % ["Stats", 10, 20])
	for index: int in Unit.Stats.size():
		print(
			(
				base_string
				% [
					"%s:" % (Unit.Stats.keys()[index] as String).capitalize(),
					_gets_stats(10)[index],
					_gets_stats(20)[index]
				]
			)
		)
	print()


func _get_greater_string(maximum: String, curr: String) -> String:
	return curr if curr.length() > maximum.length() else maximum


func _gets_stats(level: int) -> Array[int]:
	var output: Array[int] = []
	for stat: Unit.Stats in Unit.Stats.values():
		output.append(new_unit.get_stat(stat, level) - old_unit.get_stat(stat, level))
	return output
