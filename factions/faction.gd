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


func _to_string() -> String:
	return 'Faction:"{name}"<#{id}>'.format({"name": name, "id": get_instance_id()})


func get_diplomacy_stance(faction: Faction) -> DiplomacyStances:
	if faction == self:
		return DiplomacyStances.SELF
	else:
		return _diplomacy.get(faction, DiplomacyStances.ENEMY)


func set_diplomacy_stance(faction: Faction, new_stance: DiplomacyStances) -> void:
	_diplomacy[faction] = new_stance


## Returns true if the other faction is friendly (is self or ally).
func is_friend(other_faction: Faction) -> bool:
	return get_diplomacy_stance(other_faction) in [DiplomacyStances.SELF, DiplomacyStances.ALLY]


## Gets the units that belong to the faction.
func get_units() -> Array[Unit]:
	return MapController.map.get_units().filter(
		func(unit: Unit) -> bool: return unit.faction == self
	)


## Returns true if the faction is friendly to a human.
func is_friendly_to_human() -> bool:
	var is_human_friend: Callable = func(human_faction: Faction) -> bool:
		return human_faction.player_type == Faction.PlayerTypes.HUMAN and is_friend(human_faction)
	return MapController.map.all_factions.any(is_human_friend)


func get_authority() -> int:
	var units: Array[Unit] = get_units().filter(func(unit: Unit) -> bool: return unit.get_authority() > 0)
	if units.size() > 2:
		print_debug(units.map(func(unit: Unit) -> String: return unit.get_path()))
	return get_units().reduce(
		func(accumulator: int, unit: Unit) -> int: return accumulator + unit.get_authority(), 0
	)
