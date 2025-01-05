class_name Formulas
#gdlint: disable=class-variable-name
static var ATTACK := Formula.new("{weapon_might} + {attack_stat}"):
	set(value):
		pass
static var ATTACK_SPEED := Formula.new("{speed} - max({weapon_weight} - {build}, 0)"):
	set(value):
		pass
static var HIT := Formula.new("{weapon_hit} + {dexterity} * 2 + {luck}"):
	set(value):
		pass
static var AVOID := Formula.new("1.5 * ({attack_speed} + {luck})"):
	set(value):
		pass
static var CRIT := Formula.new("{weapon_crit} + {dexterity}"):
	set(value):
		pass
static var DODGE := Formula.new("{luck}"):
	set(value):
		pass
static var WEAPON_LEVEL_BONUS := Formula.new("{dexterity} * 2"):
	set(value):
		pass
#gdlint: enable=class-variable-name


class Formula:
	var _base_string: String
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

	func _init(string: String) -> void:
		_base_string = string
		for key: String in _functions.keys():
			if not _base_string.contains(key):
				_functions.erase(key)

	func _to_string() -> String:
		var regex := RegEx.new()
		regex.compile(r"{\w*}")
		var new_string: String = _base_string
		for result: RegExMatch in regex.search_all(_base_string):
			var result_string: String = result.get_string()
			new_string = new_string.replace(
				result_string, _remove_braces(result_string).capitalize()
			)
		return new_string

	func evaluate(unit: Unit) -> float:
		var replacements: Dictionary = _get_replacements(unit)
		var expression := Expression.new()
		expression.parse(_remove_braces(_base_string), replacements.keys())
		return expression.execute(replacements.values(), self)

	func format(unit: Unit) -> String:
		var replacements: Dictionary = _get_replacements(unit)
		var new_string: String = _base_string
		for key: String in replacements.keys():
			new_string = new_string.replace(
				"{%s}" % key, Utilities.float_to_string(replacements[key] as float)
			)
		return new_string

	func _get_replacements(unit: Unit) -> Dictionary:
		var replacements: Dictionary = {}
		var expression := Expression.new()
		for key: String in _functions:
			expression.parse(_functions[key] as String)
			replacements[key] = expression.execute([], unit)
		return replacements

	func _remove_braces(string: String) -> String:
		return string.replace("{", "").replace("}", "")
