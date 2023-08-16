extends Control

var observing_unit: Unit

func _ready() -> void:
	await get_tree().process_frame
	_update()
	var offensive_labels: VBoxContainer = $"Offensive Stats/HBoxContainer/Labels"
	var offensive_width: int = roundi(offensive_labels.size.x)
	var defensive_labels: VBoxContainer = $"Defensive Stats/HBoxContainer/Labels"
	var defensive_width: int = roundi(defensive_labels.size.x)
	var misc_labels: VBoxContainer = $"Misc Stats/HBoxContainer/Labels"
	var misc_width: int = roundi(misc_labels.size.x)
	var other_labels: VBoxContainer = $"Other/HBoxContainer/Labels"
	var other_width: int = roundi(other_labels.size.x)
	var max_width: int = [offensive_width, defensive_width, misc_width, other_width].max()
	offensive_labels.custom_minimum_size.x = max_width
	defensive_labels.custom_minimum_size.x = max_width
	misc_labels.custom_minimum_size.x = max_width
	other_labels.custom_minimum_size.x = max_width


func _update() -> void:
	_update_stat_bar(%"Strength Bar", Unit.stats.STRENGTH)
	_update_stat_bar(%"Pierce Bar", Unit.stats.PIERCE)
	_update_stat_bar(%"Magic Bar", Unit.stats.MAGIC)
	_update_stat_bar(%"Defense Bar", Unit.stats.MAGIC)
	_update_stat_bar(%"Durability Bar", Unit.stats.DURABILITY)
	_update_stat_bar(%"Resistance Bar", Unit.stats.RESISTANCE)
	_update_stat_bar(%"Skill Bar", Unit.stats.SKILL)
	_update_stat_bar(%"Speed Bar", Unit.stats.SPEED)
	_update_stat_bar(%"Luck Bar", Unit.stats.LUCK)
	_update_stat_bar(%"Constitution Bar", Unit.stats.CONSTITUTION)
	_update_stat_bar(%"Movement Bar", Unit.stats.MOVEMENT)
	%"Leadership Stars".stars = observing_unit.get_stat(Unit.stats.LEADERSHIP)



func _update_stat_bar(stat_bar: StatBar, stat: Unit.stats) -> void:
	stat_bar.current_value = observing_unit.get_stat(stat)
	stat_bar.max_value = observing_unit.get_stat_cap(stat)
