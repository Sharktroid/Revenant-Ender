# Object for handling factions
class_name Faction
extends RefCounted

# Valid inputs for the "player_type" field.
enum playerTypes {HUMAN, COMPUTER, NONE}
# Valid inputs for the "color" field.
enum colors {BLUE, RED, GREEN, PURPLE}
enum diplomacyStances {ALLY, PEACE, ENEMY, SELF}

var full_outline: bool = false # Whether the full outline is shown.
var name: String # Faction's name.
var color: colors # Color of all units.
var player_type: playerTypes
var outlined_units: Dictionary # The units that are outlined.
var theme: AudioStream

var _diplomacy: Dictionary


func _init(faction_name: String, faction_color: colors, faction_player_type: playerTypes,
		faction_theme: AudioStream) -> void:
	name = faction_name
	color = faction_color
	player_type = faction_player_type
	theme = faction_theme


func get_diplomacy_stance(faction: Faction) -> diplomacyStances:
	if faction == self:
		return diplomacyStances.SELF
	elif faction in _diplomacy.keys():
		return _diplomacy[faction]
	else:
		return diplomacyStances.ENEMY


func set_diplomacy_stance(faction: Faction, new_stance: diplomacyStances) -> void:
	_diplomacy[faction] = new_stance


## Returns true if the other faction is friendly (is self or ally).
func is_friend(other_faction: Faction) -> bool:
	return get_diplomacy_stance(other_faction) in [diplomacyStances.SELF, diplomacyStances.ALLY]
