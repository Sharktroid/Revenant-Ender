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
			var string_array: Array[String] = [
				"[center][colorblue]%d[/color]" % [progress_bar.value],
				" [color=%s]/[/color] " % Utilities.font_yellow,
				"[colorblue]%d[/color]\n" % [progress_bar.max_value],
				"[colorblue]%d[/color]" % [progress_bar.max_value - progress_bar.value],
				" to ",
				"[colorblue]%s[/color]" % Weapon.Ranks.find_key(roundi(progress_bar.max_value)),
				" rank[/center]",
			]
			help_description = "".join(string_array).replace(
				"colorblue", "color=%s" % Utilities.font_blue
			)


func _update_rank_bar(progress_bar: ProgressBar, rank_label: Label) -> void:
	var ranks: Array[int] = [
		Weapon.Ranks.D,
		Weapon.Ranks.C,
		Weapon.Ranks.B,
		Weapon.Ranks.A,
		Weapon.Ranks.S,
		Weapon.Ranks.S + 1
	]
	for index: int in ranks.size() - 1:
		var next_rank: int = ranks[index + 1]
		if weapon_rank < next_rank:
			var curr_rank: int = ranks[index]
			rank_label.text = Weapon.Ranks.find_key(curr_rank)
			progress_bar.min_value = curr_rank
			progress_bar.max_value = next_rank
			return
