class_name StatsPanel
extends PanelContainer

@onready var _detailed_stats: Array[HBoxContainer] = [%AttackHBox, %DefenseHBox, %AttackSpeedHBox]


func _ready() -> void:
	for hbox: HBoxContainer in _detailed_stats:
		hbox.visible = true
	for hbox: HBoxContainer in _get_invalid_hboxes():
		hbox.queue_free()


## Updates the stats that are on displayed.
func update(unit: Unit, enemy: Unit, enemy_damage: float, distance: int) -> void:
	var weapon: Weapon = unit.get_weapon()
	var in_range: bool = weapon and weapon.in_range(distance)
	var hp_progress_bar := %HPProgressBar as NumericProgressBar
	hp_progress_bar.max_value = unit.get_hit_points()
	hp_progress_bar.value = maxf(unit.current_health - enemy_damage, 0)
	hp_progress_bar.original_value = unit.current_health
	(%HPLabel as Label).text = Utilities.float_to_string(unit.current_health)

	_update_rate_label(%HitLabel as Label, unit.get_hit_rate(enemy), in_range)
	_update_rate_label(%CriticalRateLabel as Label, unit.get_crit_rate(enemy), in_range)

	if Options.COMBAT_PANEL.value == Options.COMBAT_PANEL.STRATEGIC:
		if in_range:
			_update_total_damage_label(unit, enemy, distance)
		else:
			_update_damage_label(%DamageLabel as Label, 0, in_range)
	elif Options.COMBAT_PANEL.value == Options.COMBAT_PANEL.DETAILED:
		_update_damage_label(%AttackLabel as Label, unit.get_true_attack(enemy), in_range)
		(%DefenseLabel as Label).text = Utilities.float_to_string(unit.get_current_defense(enemy))
		var attack_speed_label := %AttackSpeedLabel as Label
		attack_speed_label.text = Utilities.float_to_string(unit.get_attack_speed())
		attack_speed_label.theme_type_variation = _get_attack_speed_label_theme(
			unit, enemy, weapon, enemy.get_weapon(), distance
		)


func _get_invalid_hboxes() -> Array[HBoxContainer]:
	if Options.COMBAT_PANEL.value == Options.COMBAT_PANEL.STRATEGIC:
		return [%AttackHBox, %DefenseHBox, %AttackSpeedHBox]
	elif Options.COMBAT_PANEL.value == Options.COMBAT_PANEL.DETAILED:
		return [%DamageHBox, %CriticalDamageHBox]
	return []


func _update_damage_label(label: Label, damage: float, in_range: bool) -> void:
	label.text = Utilities.float_to_string(damage) if in_range else "--"
	# Put code for effective damage color here.
	label.theme_type_variation = &"BlueLabel" if damage > 0 and in_range else &"GrayLabel"


func _update_rate_label(label: Label, rate: int, in_range: bool) -> void:
	label.text = Utilities.float_to_string(rate) if in_range else "--"
	# Put code for effective damage color here.
	var get_type_variation: Callable = func() -> StringName:
		if rate <= 0 or not in_range:
			return &"GrayLabel"
		elif rate >= 100:
			return &"GreenLabel"
		else:
			return &"BlueLabel"
	label.theme_type_variation = get_type_variation.call()


# Gets the theme type variation for the attack speed label.
func _get_attack_speed_label_theme(
	current_unit: Unit, other_unit: Unit, weapon: Weapon, enemy_weapon: Weapon, distance: int
) -> StringName:
	if weapon and weapon.in_range(distance) and enemy_weapon and enemy_weapon.in_range(distance):
		if current_unit.can_follow_up(other_unit):
			return &"GreenLabel"
		elif other_unit.can_follow_up(current_unit):
			return &"GrayLabel"
	return &"BlueLabel"


func _update_total_damage_label(unit: Unit, enemy: Unit, distance: int) -> void:
	var total_damage: float = _get_total_damage(false, unit, enemy, distance)
	var damage_label := %DamageLabel as Label
	damage_label.text = _get_total_damage_string(unit, enemy, distance, total_damage)
	damage_label.theme_type_variation = _get_total_damage_type_variation(
		unit, distance, total_damage
	)


func _get_total_damage_string(
	unit: Unit, enemy: Unit, distance: int, total_damage: float
) -> String:
	var total_critical_damage: float = _get_total_damage(true, unit, enemy, distance)
	if total_damage == total_critical_damage:
		return Utilities.float_to_string(total_damage)
	else:
		var formatting_replacements: Dictionary = {
			"damage": Utilities.float_to_string(total_damage),
			"critical_damage": Utilities.float_to_string(total_critical_damage)
		}
		return "{damage} ({critical_damage})".format(formatting_replacements)


func _get_total_damage_type_variation(unit: Unit, distance: int, total_damage: float) -> StringName:
	if total_damage > 0 and (unit.get_weapon() and unit.get_weapon().in_range(distance)):
		return &"BlueLabel"
	else:
		return &"GrayLabel"


func _get_total_damage(crit: bool, unit: Unit, enemy: Unit, distance: int) -> float:
	var attack_queue: Array[AttackController.CombatStage] = AttackController.get_attack_queue(
		unit, distance, enemy
	)
	var get_total_damage: Callable = func(
		accumulator: float, attack: AttackController.CombatStage
	) -> float:
		if attack.attacker == unit:
			accumulator += unit.get_displayed_damage(enemy, crit)
		return accumulator
	return attack_queue.reduce(get_total_damage.bind(), 0)
