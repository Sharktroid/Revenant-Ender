class_name Spear
extends Weapon

# Weapon-specific variables.
func _init() -> void:
	_type = Types.SPEAR
	_min_range = 1
	_max_range = 1
	_advantage_types = [Types.SWORD]
	_disadvantage_types = [Types.AXE]
	_might += 10
	_hit += 85
	_weight += 10
	super()


func get_might() -> float:
	return _might - 4


func get_initial_might() -> float:
	return _might + 6

func get_stat_table() -> Table:
	var table: Table = super()
	var replacements: Dictionary[String, String] = {
		"init_might": Utilities.float_to_string(get_initial_might(), true),
		"might": Utilities.float_to_string(get_might(), true)
	}
	var might_string: String = "{init_might}/{might}".format(replacements)
	table.set_cell(Vector2i(7, 0), Table.Cell.new(might_string))
	return table
