extends PanelContainer

@export var stats: Array[Unit.Stats] = []
var unit: Unit:
	set = set_unit
var label_width: float:
	get:
		return _labels.size.x
	set(value):
		_labels.custom_minimum_size.x = value
var value_mode: bool = false:
	set(value):
		value_mode = value
		(%Bars as VBoxContainer).visible = not value_mode
		(%PersonalValues as VBoxContainer).visible = value_mode
		(%EffortValues as VBoxContainer).visible = value_mode
@onready var _labels := %Labels as VBoxContainer


func _ready() -> void:
	for stat: Unit.Stats in stats:
		var raw_stat_name := Unit.Stats.find_key(stat) as String
		var stat_name: String = raw_stat_name.capitalize()
		_labels.add_child(_get_stat_label(stat))

		var stat_bar := StatBar.instantiate(stat)
		stat_bar.name = stat_name
		%Bars.add_child(stat_bar)

		%PersonalValues.add_child(_get_personal_value_bar(stat))

		%EffortValues.add_child(_get_effort_value_bar(stat))


func set_unit(new_unit: Unit) -> void:
	unit = new_unit
	for stat: Unit.Stats in stats:
		var stat_name: String = _get_stat_name(stat)
		var stat_bar := get_node("%%Bars/%s" % stat_name) as StatBar
		stat_bar.unit = unit

		var pv_help := get_node("%%PersonalValues/%s" % stat_name) as HelpContainer
		pv_help.help_description = _get_pv_help_description(stat)
		var pv_bar := pv_help.get_node("Bar") as NumericProgressBar
		pv_bar.value = unit.get_personal_value(stat)

		var ev_help := get_node("%%EffortValues/%s" % stat_name) as HelpContainer
		ev_help.help_description = _get_ev_help_description(stat)
		var ev_bar := ev_help.get_node("Bar") as NumericProgressBar
		ev_bar.value = unit.get_effort_value(stat)


func _get_pv_help_description(stat: Unit.Stats) -> String:
	var formatting_dictionary: Dictionary[String, String] = {
		"current": str(unit.get_personal_value(stat)),
		"max": str(Unit.PV_LIMIT),
		"modifier": str(unit.get_personal_modifier(stat)),
		"yellow": "color=%s" % Utilities.FONT_YELLOW,
		"blue": "color=%s" % Utilities.FONT_BLUE,
	}
	const UNFORMATTED_DESCRIPTION: String = (
		"[center][{blue}]{current} [{yellow}]/[/color] {max}[/color][/center]\n"
		+ "[{yellow}]Modifier:[/color] [{blue}]{modifier}[/color]"
	)
	return UNFORMATTED_DESCRIPTION.format(formatting_dictionary)


func _get_ev_help_description(stat: Unit.Stats) -> String:
	var formatting_dictionary: Dictionary[String, String] = {
		"current": str(unit.get_effort_value(stat)),
		"max": str(Unit.PV_LIMIT),
		"modifier": str(unit.get_effort_modifier(stat)),
		"yellow": "color=%s" % Utilities.FONT_YELLOW,
		"blue": "color=%s" % Utilities.FONT_BLUE,
	}
	const UNFORMATTED_DESCRIPTION: String = (
		"[center][{blue}]{current} [{yellow}]/[/color] {max}[/color][/center]\n"
		+ "[{yellow}]Modifier:[/color] [{blue}]{modifier}[/color]"
	)
	return UNFORMATTED_DESCRIPTION.format(formatting_dictionary)


func _get_stat_label(stat: Unit.Stats) -> HelpContainer:
	var help_container := HelpContainer.new()
	var stat_name: String = _get_stat_name(stat)
	help_container.name = _get_stat_name(stat)
	help_container.help_description = _get_help_description(stat)
	help_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	help_container.add_to_group(&"left_nodes")

	var stat_label := Label.new()
	stat_label.text = stat_name
	stat_label.theme_type_variation = &"YellowLabel"
	help_container.add_child(stat_label)
	return help_container


func _get_personal_value_bar(stat: Unit.Stats) -> HelpContainer:
	var pv_help := HelpContainer.new()
	pv_help.name = _get_stat_name(stat)
	pv_help.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var pv_label := Label.new()
	pv_label.text = "PV: "
	pv_label.theme_type_variation = &"YellowLabel"
	pv_help.add_child(pv_label)

	var pv_bar := NumericProgressBar.instantiate(
		0, 0, Unit.PV_LIMIT, NumericProgressBar.Modes.INTEGER
	)
	pv_bar.name = "Bar"
	pv_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pv_help.add_child(pv_bar)
	return pv_help


func _get_effort_value_bar(stat: Unit.Stats) -> HelpContainer:
	var ev_help := HelpContainer.new()
	ev_help.name = _get_stat_name(stat)
	ev_help.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var ev_label := Label.new()
	ev_label.text = "EV: "
	ev_label.theme_type_variation = &"YellowLabel"
	ev_help.add_child(ev_label)

	var ev_bar := NumericProgressBar.instantiate(
		0, 0, Unit.INDIVIDUAL_EV_LIMIT, NumericProgressBar.Modes.INTEGER
	)
	ev_bar.name = "Bar"
	ev_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ev_help.add_child(ev_bar)
	return ev_help


func _get_stat_name(stat: Unit.Stats) -> String:
	var raw_stat_name := Unit.Stats.find_key(stat) as String
	return raw_stat_name.capitalize()


func _get_help_description(stat: Unit.Stats) -> String:
	match stat:
		Unit.Stats.STRENGTH:
			return "Increases the damage that physical weapons deal by +1."
		Unit.Stats.PIERCE:
			return "Increases the damage that bows and similar weapons deal by +1."
		Unit.Stats.INTELLIGENCE:
			return """Increases the damage that tomes and magical weapons deal by +1.
It also raises the duration of status staves by one turn per 5 points."""
		Unit.Stats.DEFENSE:
			return "Reduces damage from incoming physical attacks by -1."
		Unit.Stats.ARMOR:
			return "Reduces damage from incoming damage from bows and similar weapons by -1."
		Unit.Stats.RESISTANCE:
			return """Reduces the damage tomes and magical weapons deal.
It also reduces the duration of status staves by one turn per 5 points."""
		Unit.Stats.DEXTERITY:
			const DESCRIPTION: String = (
				"Increases hit rate by +{dexterity_hit_multiplier} and critical rate by +1,"
				+ " and increases every weapon's level by +{dexterity_weapon_level_multiplier}."
			)
			const REPLACEMENTS: Dictionary[String, int] = {
				"dexterity_hit_multiplier": Unit.DEXTERITY_HIT_MULTIPLIER,
			}
			return DESCRIPTION.format(REPLACEMENTS)
		Unit.Stats.SPEED:
			const DESCRIPTION: String = (
				"Increases avoid rate by +{speed_luck_avoid_multiplier}."
				+ " Can be reduced by heavy weapons."
			)
			return DESCRIPTION.format(
				{"speed_luck_avoid_multiplier": Unit.SPEED_LUCK_AVOID_MULTIPLIER}
			)
		Unit.Stats.LUCK:
			const DESCRIPTION: String = (
				"Increases hit rate and critical avoid by +1"
				+ " and avoid by +{speed_luck_avoid_multiplier}."
			)
			return DESCRIPTION.format(
				{"speed_luck_avoid_multiplier": Unit.SPEED_LUCK_AVOID_MULTIPLIER}
			)
		Unit.Stats.BUILD:
			return """Reduces weapon weight and increases weight.
Increases foot units' aid, decreases mounted units' aid."""
		Unit.Stats.MOVEMENT:
			return "Increases the amount of tiles that can be traversed in a turn."
	var stat_name := (Unit.Stats.find_key(stat) as String).capitalize()
	var error: String = 'Can not find description for stat "%s"' % stat_name
	push_error(error)
	return "Error: %s" % error
