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

@onready var _progress_bar := %ProgressBar as ProgressBar
@onready var _rank_label := %Rank as Label


func _ready() -> void:
	_update_type()


func set_as_current_help_container() -> void:
	var nodes: Array[Control] = []
	if _get_weapon_rank() > 0:
		nodes.append(_get_help_table().to_grid_container())
	else:
		nodes.append(HelpPopupController.create_text_node("This unit cannot wield weapons of this type."))
	HelpPopupController.set_help_nodes(
		[nodes], global_position + Vector2(size.x / 2, 0).round(), self
	)


func _update_type() -> void:
	const UNFORMATTED_PATH: String = "res://ui/map_ui/status_screen/item_screen/weapon_rank_label/icons/%s_icon.png"
	var type_name: String = (Weapon.Types.find_key(type) as String).to_lower()
	($Icon as TextureRect).texture = load(UNFORMATTED_PATH % type_name)


func _update_rank() -> void:
	if _get_weapon_rank() < Weapon.Ranks.D:
		_rank_label.text = "-"
		_progress_bar.value = 0
	else:
		_update_rank_bar(_progress_bar, _rank_label)
		_progress_bar.value = _get_weapon_rank()


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


#func _get_formatting_dictionary() -> Dictionary:
	#return {
		#"current value": _progress_bar.value,
		#"yellow": "color=%s" % Utilities.FONT_YELLOW,
		#"max value": _progress_bar.max_value,
		#"remaining value": _progress_bar.max_value - _progress_bar.value,
		#"rank": Weapon.Ranks.find_key(roundi(_progress_bar.max_value)),
		#"blue": "color=%s" % Utilities.FONT_BLUE,
		#"class value": unit.unit_class.get_base_weapon_level(type),
		#"personal value": unit.personal_weapon_levels.get(type, 0),
		##"skill value": Formulas.WEAPON_LEVEL_BONUS.evaluate(unit),
		#"total": unit.get_weapon_level(type),
	#}


func _get_help_table() -> Table:
	var table_dict: Dictionary[String, String] = {
		"Class": str(Weapon.Ranks.find_key(unit.unit_class.get_weapon_level(type))),
	}
	return Table.from_dictionary(table_dict, 1)


#func _get_help_description() -> String:
	#if _get_weapon_rank() >= Weapon.Ranks.S:
		#return "This unit has maxed out their\nrank for this weapon"
	#elif _get_weapon_rank() < Weapon.Ranks.D:
		#return "This unit cannot wield weapons of this type"
	#else:
		#const UNFORMATTED_DESCRIPTION: String = (
			#"[center][{blue}]{current value}[/color] [{yellow}]/[/color] "
			#+ "[{blue}]{max value}[/color]\n"
			#+ "[{blue}]{remaining value}[/color] to [{blue}]{rank}[/color] rank[/center]\n"
		#)
		#return UNFORMATTED_DESCRIPTION.format(_get_formatting_dictionary())
