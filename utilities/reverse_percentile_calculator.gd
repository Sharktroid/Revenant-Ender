extends PanelContainer

var base_stat: int
var promo_gain: int
var growth: float
var unpromo_level: int
var starting_level: int
var promo_level: int
var percentile: float

func _ready() -> void:
	_update()


func _update() -> void:
	($VBoxContainer/Result as Label).text = "Result: %d" % _get_lowest_match()

func _factorial(num: int) -> float:
	var product: float = 1
	for mult: int in num:
		product *= mult + 1
	return product


func _binomial_formula(value: int, probability: float, total: int) -> float:
	var permutations: float = float(_factorial(total)) / (_factorial(total - value))
	var combinations: float = permutations / _factorial(value)
	return combinations * (probability ** value) * ((1 - probability) ** (total - value))

func _get_lowest_match() -> int:
	var curr_percentile: float = 1.0
	for leveled_stat in range(_get_levels() + 1):
		curr_percentile -= _binomial_formula(leveled_stat, growth, _get_levels())
		if curr_percentile < percentile:
			return _get_stat_sum() + leveled_stat
	return _get_stat_sum() + _get_levels()

func _get_stat_sum() -> int:
	return base_stat + (promo_gain if promo_level > 0 else 0)


func _get_levels() -> int:
	return unpromo_level - starting_level + (promo_level - 1 if promo_level > 0 else 0)


func _on_base_edit_text_changed(new_text: String) -> void:
	base_stat = int(new_text)
	_update()


func _on_promo_edit_text_changed(new_text: String) -> void:
	promo_gain = int(new_text)
	_update()


func _on_starting_level_edit_text_changed(new_text: String) -> void:
	starting_level = int(new_text)
	_update()


func _on_unpromoted_level_edit_text_changed(new_text: String) -> void:
	unpromo_level = int(new_text)
	_update()


func _on_promoted_level_edit_text_changed(new_text: String) -> void:
	promo_level = int(new_text)
	(%PromoEdit as LineEdit).editable = promo_level > 0
	_update()


func _on_growth_edit_text_changed(new_text: String) -> void:
	growth = roundf(float(new_text)) / 100
	_update()


func _on_percentile_edit_text_changed(new_text: String) -> void:
	percentile = float(new_text)
	_update()
