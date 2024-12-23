@tool
extends EditorScript

var old_class: UnitClass = Knight.new()
var new_class: UnitClass = Cavalier.new()
var old_unit: Unit
var new_unit: Unit


func _run() -> void:
	var name: String = "SOUND_EFFECTS"
	var settings: Array[String] = ["3", "2", "1", "Off"]
	print(
		(
			"""\n\nclass %sOption:
	extends StringNameOption\n"""
			% name.to_pascal_case()
		)
	)
	for setting: String in settings:
		var snake: String = setting.to_snake_case()
		print(
			'\tconst {constant}: StringName = &"{snake}"'.format(
				{"constant": snake.to_upper(), "snake": snake}
			)
		)
	print(
		(
			"""\n\tfunc _init() -> void:
		_id = &"%s"
		_default = """
			% name.to_snake_case()
		)
	)
	#old_unit = Unit.new()
	#old_unit.unit_class = old_class
	#new_unit = Unit.new()
	#new_unit.unit_class = new_class
	#var max_length: int = ((Unit.Stats.keys().reduce(_get_greater_string) as String).length()) + 1
	#var base_string: String = "%-{length}s %3d %3d".format({"length": max_length})
	#print(base_string % ["Stats", 10, 20])
	#for index: int in Unit.Stats.size():
	#print(
	#(
	#base_string
	#% [
	#"%s:" % (Unit.Stats.keys()[index] as String).capitalize(),
	#_gets_stats(10)[index],
	#_gets_stats(20)[index]
	#]
	#)
	#)
	#print()


func _get_greater_string(maximum: String, current: String) -> String:
	return current if current.length() > maximum.length() else maximum


func _gets_stats(level: int) -> Array[int]:
	var output: Array[int] = []
	for stat: Unit.Stats in Unit.Stats.values():
		output.append(new_unit.get_stat(stat, level) - old_unit.get_stat(stat, level))
	return output
