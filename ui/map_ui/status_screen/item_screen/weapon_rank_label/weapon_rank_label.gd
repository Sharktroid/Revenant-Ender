@tool
extends HelpContainer

@export var icon: Texture2D:
	set(value):
		icon = value
		($Icon as TextureRect).texture = icon

var weapon_rank: int:
	set(value):
		weapon_rank = clampi(value, 0, Weapon.Ranks.S)
		_update_rank()


func _update_rank() -> void:
	var progress_bar := %ProgressBar as ProgressBar
	var rank_label := %Rank as Label
	if weapon_rank < Weapon.Ranks.D:
		rank_label.text = "-"
		progress_bar.value = 0
		help_description = "This unit cannot wield weapons of this type"

	else:
		_update_rank_bar(progress_bar, rank_label)
		progress_bar.value = weapon_rank
		if rank_label.text == "S":
			help_description = "This unit has maxed out their rank for this weapon"
		else:
			const UNFORMATTED_DESCRIPTION: String = (
				"[center][{blue}]{current value}[/color] [color={yellow}]/[/color] "
				+ "[{blue}]{max value}[/color]\n"
				+ "[{blue}]{remaining value}[/color] to [{blue}]{rank}[/color] rank[/center]"
			)
			var formatting_dictionary: Dictionary = {
				"current value": progress_bar.value,
				"yellow": Utilities.font_yellow,
				"max value": progress_bar.max_value,
				"remaining value": progress_bar.max_value - progress_bar.value,
				"rank": Weapon.Ranks.find_key(roundi(progress_bar.max_value)),
				"blue": "color=%s" % Utilities.font_blue
			}
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
		if weapon_rank < next_rank:
			var current_rank: int = RANKS[index]
			rank_label.text = Weapon.Ranks.find_key(current_rank)
			progress_bar.min_value = current_rank
			progress_bar.max_value = next_rank
			return
