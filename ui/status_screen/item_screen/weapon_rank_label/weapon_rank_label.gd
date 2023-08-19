@tool
extends HBoxContainer

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
	if weapon_rank < Weapon.ranks.E:
		%Rank.text = "-"
		%ProgressBar.value = 0

	else:
		if weapon_rank < Weapon.ranks.D:
			%Rank.text = "E"
			%ProgressBar.min_value = Weapon.ranks.E
			%ProgressBar.max_value = Weapon.ranks.D

		elif weapon_rank < Weapon.ranks.C:
			%Rank.text = "D"
			%ProgressBar.min_value = Weapon.ranks.D
			%ProgressBar.max_value = Weapon.ranks.C

		elif weapon_rank < Weapon.ranks.B:
			%Rank.text = "C"
			%ProgressBar.min_value = Weapon.ranks.C
			%ProgressBar.max_value = Weapon.ranks.B

		elif weapon_rank < Weapon.ranks.A:
			%Rank.text = "B"
			%ProgressBar.min_value = Weapon.ranks.B
			%ProgressBar.max_value = Weapon.ranks.A

		elif weapon_rank < Weapon.ranks.S:
			%Rank.text = "A"
			%ProgressBar.min_value = Weapon.ranks.A

			%ProgressBar.max_value = Weapon.ranks.S
		else:
			%Rank.text = "S"
			%ProgressBar.min_value = Weapon.ranks.S
			%ProgressBar.max_value = 255

		%ProgressBar.value = weapon_rank
