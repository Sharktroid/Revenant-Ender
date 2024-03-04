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
	$Icon.texture = icon


func _update_rank() -> void:
	var progress_bar: ProgressBar = %ProgressBar
	if weapon_rank < Weapon.ranks.E:
		%Rank.text = "-"
		progress_bar.value = 0
		help_description = "This unit cannot wield weapons of this type"

	else:
		if weapon_rank < Weapon.ranks.D:
			%Rank.text = "E"
			progress_bar.min_value = Weapon.ranks.E
			progress_bar.max_value = Weapon.ranks.D

		elif weapon_rank < Weapon.ranks.C:
			%Rank.text = "D"
			progress_bar.min_value = Weapon.ranks.D
			progress_bar.max_value = Weapon.ranks.C

		elif weapon_rank < Weapon.ranks.B:
			%Rank.text = "C"
			progress_bar.min_value = Weapon.ranks.C
			progress_bar.max_value = Weapon.ranks.B

		elif weapon_rank < Weapon.ranks.A:
			%Rank.text = "B"
			progress_bar.min_value = Weapon.ranks.B
			progress_bar.max_value = Weapon.ranks.A

		elif weapon_rank < Weapon.ranks.S:
			%Rank.text = "A"
			progress_bar.min_value = Weapon.ranks.A

			progress_bar.max_value = Weapon.ranks.S
		else:
			%Rank.text = "S"
			progress_bar.min_value = Weapon.ranks.S
			progress_bar.max_value = 255

		progress_bar.value = weapon_rank
		if %Rank.text == "S":
			help_description = "This unit has maxed out their rank for this weapon"
		else:
			var color_blue: String = "color=%s" % Utilities.font_blue
			var string_array: Array[String] = [
				"[colorblue]%d[/color]" % [progress_bar.min_value],
				" [color=%s]/[/color] " % Utilities.font_yellow,
				"[colorblue]%d[/color]\n" % [progress_bar.max_value],
				"[colorblue]%d[/color]" % [progress_bar.max_value - progress_bar.value],
				" to ",
				"[colorblue]%s[/color]" % Weapon.ranks.find_key(roundi(progress_bar.max_value)),
				" rank",
			]
			help_description = "".join(string_array).replace("colorblue", color_blue)
