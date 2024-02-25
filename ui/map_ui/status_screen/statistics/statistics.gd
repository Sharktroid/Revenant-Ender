extends Control

var observing_unit: Unit


func update() -> void:
	var offensive_labels: VBoxContainer = $"Offensive Stats/HBoxContainer/Labels"
	var defensive_labels: VBoxContainer = $"Defensive Stats/HBoxContainer/Labels"
	var misc_labels: VBoxContainer = $"Misc Stats/HBoxContainer/Labels"
	var other_labels: VBoxContainer = $"Other/HBoxContainer/Labels"
	var max_width: int = [
		roundi(offensive_labels.size.x),
		roundi(defensive_labels.size.x),
		roundi(misc_labels.size.x),
		roundi(other_labels.size.x)].max()
	offensive_labels.custom_minimum_size.x = max_width
	defensive_labels.custom_minimum_size.x = max_width
	misc_labels.custom_minimum_size.x = max_width
	other_labels.custom_minimum_size.x = max_width

	_update_stat_bar(%"Strength Bar" as StatBar, Unit.stats.STRENGTH)
	_update_stat_bar(%"Pierce Bar" as StatBar, Unit.stats.PIERCE)
	_update_stat_bar(%"Magic Bar" as StatBar, Unit.stats.MAGIC)
	_update_stat_bar(%"Defense Bar" as StatBar, Unit.stats.DEFENSE)
	_update_stat_bar(%"Durability Bar" as StatBar, Unit.stats.DURABILITY)
	_update_stat_bar(%"Resistance Bar" as StatBar, Unit.stats.RESISTANCE)
	_update_stat_bar(%"Skill Bar" as StatBar, Unit.stats.SKILL)
	_update_stat_bar(%"Speed Bar" as StatBar, Unit.stats.SPEED)
	_update_stat_bar(%"Luck Bar" as StatBar, Unit.stats.LUCK)
	_update_stat_bar(%"Constitution Bar" as StatBar, Unit.stats.CONSTITUTION)
	_update_stat_bar(%"Movement Bar" as StatBar, Unit.stats.MOVEMENT)

	%"Weight Value".text = str(observing_unit.get_weight())
	if observing_unit.get_aid() < 0:
		%"Aid Value".text = "-"
	else:
		%"Aid Value".text = str(observing_unit.get_aid())
	%"Authority Stars".stars = observing_unit.get_stat(Unit.stats.AUTHORITY)
	if observing_unit.traveler:
		%"Traveler Name".text = observing_unit.traveler.name
	else:
		%"Traveler Name".text = "-"

	%"Weight Help".help_description = "%d + %d" % [
		observing_unit.get_stat(Unit.stats.CONSTITUTION),
		observing_unit.unit_class.weight_modifier
	]
	if observing_unit.unit_class.aid_modifier < 0:
		%"Aid Help".help_description = "%d - %d" % [
			observing_unit.get_stat(Unit.stats.CONSTITUTION),
			-observing_unit.unit_class.aid_modifier
		]
	elif observing_unit.unit_class.aid_modifier == 0:
		%"Aid Help".help_description = ("%d + 0" %
				[observing_unit.get_stat(Unit.stats.CONSTITUTION)])
	else:
		%"Aid Help".help_description = "%d - %d" % [
			observing_unit.unit_class.aid_modifier,
			observing_unit.get_stat(Unit.stats.CONSTITUTION)
		]


func _update_stat_bar(stat_bar: StatBar, stat: Unit.stats) -> void:
	stat_bar.unit = observing_unit
	stat_bar.stat = stat
	stat_bar.update.call_deferred()


func _on_strength_label_visibility_changed() -> void:
	if observing_unit:
		pass
		#update()
