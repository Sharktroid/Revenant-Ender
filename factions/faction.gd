# Object for handling factions
class_name Faction
extends RefCounted

# Valid inputs for the "player_type" field.
enum player_types {HUMAN, COMPUTER, NONE}
# Valid inputs for the "color" field.
enum colors {BLUE, RED, GREEN, PURPLE}
enum diplo_stances {ALLY, PEACE, ENEMY, SELF}

var full_outline: bool = false # Whether the full outline is shown.
var name: String # Faction's name.
var color: colors # Color of all units.
var player_type: player_types
var outlined_units: Dictionary # The units that are outlined.

var _diplomacy: Dictionary


func _init(faction_name: String, faction_color: colors, faction_player_type: player_types):
	name = faction_name
	color = faction_color
	player_type = faction_player_type


func get_diplomacy_stance(faction: Faction) -> diplo_stances:
	if faction == self:
		return diplo_stances.SELF
	elif faction in _diplomacy.keys():
		return _diplomacy[faction]
	else:
		return diplo_stances.ENEMY


func set_diplomacy_stance(faction: Faction, new_stance: diplo_stances) -> void:
	_diplomacy[faction] = new_stance


## Returns true if the other faction is friendly (is self or ally).
func is_friend(other_faction: Faction) -> bool:
	return get_diplomacy_stance(other_faction) in [diplo_stances.SELF, diplo_stances.ALLY]
