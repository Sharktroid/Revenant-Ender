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
static var CRITICAL_AVOID := Formula.new("{luck}"):
	set(value):
		pass
#static var WEAPON_LEVEL_BONUS := Formula.new("{dexterity} * {dexterity_weapon_level_multiplier}"):
	#set(value):
		#pass
#gdlint: enable=class-variable-name


## A class that represents a formula.
class Formula:
	const _CONSTANTS: Dictionary[String, int] = {
		"dexterity_hit_multiplier": Unit.DEXTERITY_HIT_MULTIPLIER,
		"speed_luck_avoid_multiplier": Unit.SPEED_LUCK_AVOID_MULTIPLIER,
	}
	var _functions: Dictionary[String, Callable] = {
		"weapon_hit": func(unit: Unit) -> float: return unit.get_weapon().get_hit() if unit.get_weapon() else 0.0,
		"weapon_crit": func(unit: Unit) -> float: return unit.get_weapon().get_crit() if unit.get_weapon() else 0.0,
		"weapon_might": func(unit: Unit) -> float: return unit.get_weapon().get_might() if unit.get_weapon() else 0.0,
		"weapon_weight": func(unit: Unit) -> float: return unit.get_weapon().get_weight() if unit.get_weapon() else 0.0,
		"dexterity": func(unit: Unit) -> int: return unit.get_dexterity(),
		"speed": func(unit: Unit) -> int: return unit.get_speed(),
		"luck": func(unit: Unit) -> int: return unit.get_luck(),
		"build": func(unit: Unit) -> int: return unit.get_build(),
		"attack_stat": func(unit: Unit) -> int: return unit.get_current_attack(),
		"attack_speed": func(unit: Unit) -> float: return unit.get_attack_speed(),
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
		var replacements: Dictionary[String, float] = _get_all_replacements(unit)
		var expression := Expression.new()
		expression.parse(_remove_braces(_base_string), replacements.keys())
		return expression.execute(replacements.values(), self)

	## Turns the formula into an equation.
	func format(unit: Unit) -> String:
		return _format_string(_base_string, _get_all_replacements(unit))

	func _format_string(string: String, replacements: Dictionary[String, float]) -> String:
		for key: String in replacements.keys():
			string = string.replace(
				"{%s}" % key, Utilities.float_to_string(replacements[key] as float)
			)
		return string

	func _get_constant_replacements() -> Dictionary[String, float]:
		var replacements: Dictionary[String, float] = {}
		var expression := Expression.new()
		for key: String in _CONSTANTS:
			expression.parse(str(_CONSTANTS[key]))
			replacements[key] = expression.execute([])
		return replacements

	func _get_function_replacements(unit: Unit) -> Dictionary[String, float]:
		var replacements: Dictionary[String, float] = {}
		for key: String in _functions:
			replacements[key] = _functions[key].call(unit)
		return replacements

	func _get_all_replacements(unit: Unit) -> Dictionary[String, float]:
		return _get_constant_replacements().merged(_get_function_replacements(unit))

	func _remove_braces(string: String) -> String:
		return string.replace("{", "").replace("}", "")
