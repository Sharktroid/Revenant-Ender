# Object for handling factions
class_name Faction
extends RefCounted

# Valid inputs for the "player_type" field.
enum PlayerTypes { HUMAN, COMPUTER, NONE }
# Valid inputs for the "color" field.
enum Colors { BLUE, RED, GREEN, PURPLE }
enum DiplomacyStances { ALLY, PEACE, ENEMY, SELF }

var full_outline: bool = false  # Whether the full outline is shown.
var name: String  # Faction's name.
var color: Colors  # Color of all units.
var player_type: PlayerTypes
var outlined_units: Dictionary  # The units that are outlined.
var theme: AudioStream
var flipped: bool

var _diplomacy: Dictionary


func _init(
	faction_name: String,
	faction_color: Colors,
	faction_player_type: PlayerTypes,
	faction_theme: AudioStream,
	flip: bool = false
) -> void:
	name = faction_name
	color = faction_color
	player_type = faction_player_type
	theme = faction_theme
	flipped = flip


func get_diplomacy_stance(faction: Faction) -> DiplomacyStances:
	return (
		DiplomacyStances.SELF if faction == self
		else _diplomacy.get(faction, DiplomacyStances.ENEMY)
	)


func set_diplomacy_stance(faction: Faction, new_stance: DiplomacyStances) -> void:
	_diplomacy[faction] = new_stance


## Returns true if the other faction is friendly (is self or ally).
func is_friend(other_faction: Faction) -> bool:
	return get_diplomacy_stance(other_faction) in [DiplomacyStances.SELF, DiplomacyStances.ALLY]
