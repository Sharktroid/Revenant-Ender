extends Control

const _STATS_PANEL: GDScript = preload(
	"res://ui/map_ui/status_screen/statistics/stats_panel/stats_panel.gd"
)
var observing_unit: Unit:
	set(value):
		observing_unit = value
		_update()

@onready var offensive_stats_panel := %OffensiveStats as _STATS_PANEL
@onready var defensive_stats_panel := %DefensiveStats as _STATS_PANEL
@onready var misc_stats_panel := %MiscStats as _STATS_PANEL


func _ready() -> void:
	visibility_changed.connect(_update)
	_update_width()
	const FORMATTING_DICTIONARY: Dictionary[String, int] = {
		"authority_hit_bonus": Unit.AUTHORITY_HIT_BONUS,
		"authority_critical_avoid_bonus": Unit.AUTHORITY_CRITICAL_AVOID_BONUS,
	}
	var authority_help := %AuthorityHelp as HelpContainer
	authority_help.help_description = authority_help.help_description.format(
		FORMATTING_DICTIONARY
	)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ranges"):
		offensive_stats_panel.value_mode = not offensive_stats_panel.value_mode
		defensive_stats_panel.value_mode = not defensive_stats_panel.value_mode
		misc_stats_panel.value_mode = not misc_stats_panel.value_mode


func get_left_controls() -> Array[Node]:
	return get_tree().get_nodes_in_group(&"left_nodes")


func _update() -> void:
	if visible and observing_unit:
		offensive_stats_panel.unit = observing_unit
		defensive_stats_panel.unit = observing_unit
		misc_stats_panel.unit = observing_unit

		(%WeightValue as Label).text = str(observing_unit.get_weight())
		(%AidValue as Label).text = (
			"-" if observing_unit.get_aid() < 0 else str(observing_unit.get_aid())
		)
		const StarsLabel: GDScript = preload(
			"res://ui/map_ui/status_screen/statistics/stars_label/stars_label.gd"
		)
		(%AuthorityStars as StarsLabel).stars = observing_unit.get_authority()
		(%TravelerName as Label).text = (
			observing_unit.traveler.name as String if observing_unit.traveler else "-"
		)

		(%WeightNumber as HelpContainer).help_description = _get_weight_description()
		(%AidNumber as HelpContainer).help_description = _get_aid_description()


func _get_weight_description() -> String:
	var format_dictionary: Dictionary[String, int] = {
		"build": observing_unit.get_build(),
		"weight_modifier": observing_unit.unit_class.get_weight_modifier()
	}
	return "{build} + {weight_modifier}".format(format_dictionary)


func _get_aid_description() -> String:
	var aid_modifier: int = observing_unit.unit_class.get_aid_modifier()
	var get_unformatted_aid_description: Callable = func() -> String:
		match sign(aid_modifier):
			1:
				return "{aid_modifier} - {build}"
			-1:
				return "{build} - {aid_modifier}"
			_:
				return "{build}"
	var aid_description: String = get_unformatted_aid_description.call()
	var format_dictionary: Dictionary[String, int] = {
		"build": observing_unit.get_build(), "aid_modifier": absi(aid_modifier)
	}
	return aid_description.format(format_dictionary)


func _update_stat_bar(stat_bar: StatBar, stat: Unit.Stats) -> void:
	stat_bar.unit = observing_unit
	stat_bar.stat = stat


func _update_width() -> void:
	var other_labels := %OtherLabels as VBoxContainer
	var max_width: int = max(
		roundi(offensive_stats_panel.label_width),
		roundi(defensive_stats_panel.label_width),
		roundi(misc_stats_panel.label_width),
		roundi(other_labels.size.x)
	)
	offensive_stats_panel.label_width = max_width
	defensive_stats_panel.label_width = max_width
	misc_stats_panel.label_width = max_width
	other_labels.custom_minimum_size.x = max_width
