@tool
extends HelpContainer

@export var icon: Texture2D:
	set(value):
		icon = value
		_update_icon()

var weapon_rank: int:
	set(value):
		weapon_rank = value
		_update_rank()


func _update_icon() -> void:
	($Icon as TextureRect).texture = icon


func _update_rank() -> void:
	var progress_bar := %ProgressBar as ProgressBar
	var rank_label := %Rank as Label
	if weapon_rank < Weapon.Ranks.E:
		rank_label.text = "-"
		progress_bar.value = 0
		help_description = "This unit cannot wield weapons of this type"

	else:
		if weapon_rank < Weapon.Ranks.D:
			rank_label.text = "E"
			progress_bar.min_value = Weapon.Ranks.E
			progress_bar.max_value = Weapon.Ranks.D

		elif weapon_rank < Weapon.Ranks.C:
			rank_label.text = "D"
			progress_bar.min_value = Weapon.Ranks.D
			progress_bar.max_value = Weapon.Ranks.C

		elif weapon_rank < Weapon.Ranks.B:
			rank_label.text = "C"
			progress_bar.min_value = Weapon.Ranks.C
			progress_bar.max_value = Weapon.Ranks.B

		elif weapon_rank < Weapon.Ranks.A:
			rank_label.text = "B"
			progress_bar.min_value = Weapon.Ranks.B
			progress_bar.max_value = Weapon.Ranks.A

		elif weapon_rank < Weapon.Ranks.S:
			rank_label.text = "A"
			progress_bar.min_value = Weapon.Ranks.A

			progress_bar.max_value = Weapon.Ranks.S
		else:
			rank_label.text = "S"
			progress_bar.min_value = Weapon.Ranks.S
			progress_bar.max_value = 255

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
				(
					"[colorblue]%s[/color]"
					% (Weapon.Ranks as Dictionary).find_key(roundi(progress_bar.max_value))
				),
				" rank[/center]",
			]
			help_description = "".join(string_array).replace(
				"colorblue", "color=%s" % Utilities.font_blue
			)
