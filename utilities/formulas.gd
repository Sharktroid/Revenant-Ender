class_name Formulas
#gdlint: disable=class-variable-name
## Gets the amount of points of hit for every point of dexterity.
static var ATTACK := Formula.new("{weapon_might} + {attack_stat}"):
	set(value):
		pass
static var ATTACK_SPEED := Formula.new("{speed} - max({weapon_weight} - {build}, 0)"):
	set(value):
		pass
static var HIT := Formula.new("{weapon_hit} + {dexterity} * {dexterity_hit_multiplier} + {luck}"):
	set(value):
		pass
static var AVOID := Formula.new("{speed_luck_avoid_multiplier} * ({attack_speed} + {luck})"):
	set(value):
		pass
static var CRIT := Formula.new("{weapon_crit} + {dexterity}"):
	set(value):
		pass
static var DODGE := Formula.new("{luck}"):
	set(value):
		pass
static var WEAPON_LEVEL_BONUS := Formula.new("{dexterity} * {dexterity_weapon_level_multiplier}"):
	set(value):
		pass
#gdlint: enable=class-variable-name


## A class that represents a formula.
class Formula:
	const _CONSTANTS: Dictionary = {
		"dexterity_hit_multiplier": 3,
		"speed_luck_avoid_multiplier": 2,
		"dexterity_weapon_level_multiplier": 2,
	}
	var _functions: Dictionary = {
		"weapon_hit": "get_weapon().get_hit()",
		"weapon_crit": "get_weapon().get_crit()",
		"weapon_might": "get_weapon().get_might()",
		"weapon_weight": "get_weapon().get_weight()",
		"dexterity": "get_dexterity()",
		"speed": "get_speed()",
		"luck": "get_luck()",
		"build": "get_build()",
		"attack_stat": "get_current_attack()",
		"attack_speed": "get_attack_speed()",
	}
	var _base_string: String

	func _init(string: String) -> void:
		_base_string = string
		for key: String in _functions.keys():
			if not _base_string.contains(key):
				_functions.erase(key)

	func _to_string() -> String:
		var regex := RegEx.new()
		regex.compile(r"{\w*}")
		var new_string: String = _format_string(_base_string, _get_constant_replacements())
		for result: RegExMatch in regex.search_all(_base_string):
			var result_string: String = result.get_string()
			new_string = new_string.replace(
				result_string, _remove_braces(result_string).capitalize()
			)
		return new_string

	## Gets the result of the formula.
	func evaluate(unit: Unit) -> float:
		var replacements: Dictionary = _get_all_replacements(unit)
		var expression := Expression.new()
		expression.parse(_remove_braces(_base_string), replacements.keys())
		return expression.execute(replacements.values(), self)

	## Turns the formula into an equation.
	func format(unit: Unit) -> String:
		return _format_string(_base_string, _get_all_replacements(unit))

	func _format_string(string: String, replacements: Dictionary) -> String:
		for key: String in replacements.keys():
			string = string.replace(
				"{%s}" % key, Utilities.float_to_string(replacements[key] as float)
			)
		return string

	func _get_constant_replacements() -> Dictionary:
		var replacements: Dictionary = {}
		var expression := Expression.new()
		for key: String in _CONSTANTS:
			expression.parse(str(_CONSTANTS[key]))
			replacements[key] = expression.execute([])
		return replacements

	func _get_function_replacements(unit: Unit) -> Dictionary:
		var replacements: Dictionary = {}
		var expression := Expression.new()
		for key: String in _functions:
			expression.parse(str(_functions[key]))
			replacements[key] = expression.execute([], unit)
		return replacements

	func _get_all_replacements(unit: Unit) -> Dictionary:
		return _get_constant_replacements().merged(_get_function_replacements(unit))

	func _remove_braces(string: String) -> String:
		return string.replace("{", "").replace("}", "")
