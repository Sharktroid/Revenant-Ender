@tool
extends HelpContainer

@export var type: Weapon.Types:
	set(value):
		type = value
		_update_type()

var unit: Unit:
	set(value):
		unit = value
		_update_rank()


func _ready() -> void:
	_update_type()


func _update_type() -> void:
	const UNFORMATTED_PATH: String = (
		"res://ui/map_ui/status_screen/item_screen/weapon_rank_label/icons/%s_icon.png"
	)
	var type_name: String = (Weapon.Types.find_key(type) as String).to_lower()
	print_debug(type_name)
	($Icon as TextureRect).texture = load(UNFORMATTED_PATH % type_name)


func _update_rank() -> void:
	var progress_bar := %ProgressBar as ProgressBar
	var rank_label := %Rank as Label
	if _get_weapon_rank() < Weapon.Ranks.D:
		rank_label.text = "-"
		progress_bar.value = 0
		help_description = "This unit cannot wield weapons of this type"

	else:
		_update_rank_bar(progress_bar, rank_label)
		progress_bar.value = _get_weapon_rank()
		const UNFORMATTED_TABLE: Array[String] = [
			"[{yellow}]Class:[/color] [{blue}]{class value}[/color]\n",
			"[{yellow}]Personal:[/color] [{blue}]{personal value}[/color]\n",
			"[{yellow}]Skill bonus:[/color] [{blue}]{skill value}[/color]\n",
			"[{yellow}]Total:[/color] [{blue}]{total}[/color]\n",
		]
		var formatting_dictionary: Dictionary = {
			"current value": progress_bar.value,
			"yellow": "color=%s" % Utilities.font_yellow,
			"max value": progress_bar.max_value,
			"remaining value": progress_bar.max_value - progress_bar.value,
			"rank": Weapon.Ranks.find_key(roundi(progress_bar.max_value)),
			"blue": "color=%s" % Utilities.font_blue,
			"class value": unit.unit_class.get_base_weapon_level(type),
			"personal value": unit.personal_weapon_levels.get(type, 0),
			"skill value": Formulas.WEAPON_LEVEL_BONUS.evaluate(unit),
			"total": unit.get_weapon_level(type),
		}
		var format: Callable = func(string: String) -> String:
			return string.format(formatting_dictionary)
		help_table.assign(UNFORMATTED_TABLE.map(format))
		table_columns = 2
		if rank_label.text == "S":
			help_description = "This unit has maxed out their\nrank for this weapon"
		else:
			const UNFORMATTED_DESCRIPTION: String = (
				"[center][{blue}]{current value}[/color] [{yellow}]/[/color] "
				+ "[{blue}]{max value}[/color]\n"
				+ "[{blue}]{remaining value}[/color] to [{blue}]{rank}[/color] rank[/center]\n"
			)
			help_description = UNFORMATTED_DESCRIPTION.format(formatting_dictionary)


func _update_rank_bar(progress_bar: ProgressBar, rank_label: Label) -> void:
	const RANKS: Array[int] = [
		Weapon.Ranks.D,
		Weapon.Ranks.C,
		Weapon.Ranks.B,
		Weapon.Ranks.A,
		Weapon.Ranks.S,
		Weapon.Ranks.S + 1
	]
	for index: int in RANKS.size() - 1:
		var next_rank: int = RANKS[index + 1]
		if _get_weapon_rank() < next_rank:
			var current_rank: int = RANKS[index]
			rank_label.text = Weapon.Ranks.find_key(current_rank)
			progress_bar.min_value = current_rank
			progress_bar.max_value = next_rank
			return


func _get_weapon_rank() -> int:
	return unit.get_weapon_level(type)
