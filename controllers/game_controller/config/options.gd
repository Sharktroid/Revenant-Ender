## A [Node] that stores options
extends Node

#gdlint: disable = class-variable-name
# Controls what animations play
## @experimental Currently does nothing
var ANIMATIONS := AnimationsOption.new()
# Controls how fast the units move
## @experimental Currently does nothing.
var GAME_SPEED := GameSpeedOption.new()
# Controls how fast the text scrolls
## @experimental Currently does nothing.
var TEXT_SPEED := TextSpeedOption.new()
# Controls how fast the units move
## @experimental Currently does nothing.
var TERRAIN := BooleanOption.new(&"terrain", &"options", true, "Set Terrain window display.")
## @experimental Currently does nothing.
var UNIT_PANEL := UnitPanelOption.new()
## @experimental Currently does nothing.
var COMBAT_PANEL := CombatPanelOption.new()
## @experimental Currently does nothing.
var AUTOCURSOR := BooleanOption.new(
	&"autocursor", &"options", true, "Set cursor to start on main hero."
)
## @experimental Currently does nothing.
var AUTOEND_TURNS := BooleanOption.new(
	&"autoend_turns", &"options", true, "Set turn to end automatically."
)
## @experimental Changes the volume of the music
var MUSIC := FloatOption.new(&"music_volume", &"options", 1.0, 0.0, 1.0, "Set music volume.")
## @experimental Changes the volume of sound effects.
var SOUND_EFFECTS := FloatOption.new(
	&"sound_effect_volume", &"options", 1.0, 0.0, 1.0, "Set sound effect volume."
)
## @experimental Currently does nothing.
var UNIT_PALETTE := BooleanOption.new(
	&"unit_palette", &"options", true, "Sets allies personal colors."
)
#gdlint: enable = class-variable-name


## Gets the full list of the [ConfigOption]s in use.
func get_options() -> Array[ConfigOption]:
	return [
		ANIMATIONS,
		GAME_SPEED,
		TEXT_SPEED,
		TERRAIN,
		UNIT_PANEL,
		COMBAT_PANEL,
		AUTOCURSOR,
		AUTOEND_TURNS,
		MUSIC,
		SOUND_EFFECTS,
		UNIT_PALETTE,
	]


## @experimental
## A [StringNameOption] for animations.
class AnimationsOption:
	extends StringNameOption

	# All attack animations are battle animations
	## @experimental
	## Currently does nothing
	const ALL: StringName = &"all"
	# All attack animations are battle animations except for trivial enemies
	## @experimental
	## Currently does nothing
	const MOST: StringName = &"most"
	# All attack animations are map animations except for bosses
	## @experimental
	## Currently does nothing
	const SOME: StringName = &"some"
	# All attack animations are skipped animations except for bosses which are map apart from a few
	## @experimental
	## Currently does nothing
	const FEW: StringName = &"few"

	func _init() -> void:
		_name = &"animation_option"
		_default = ALL
		_settings = [ALL, MOST, SOME, FEW]
		super()

	func get_description(option: StringName) -> String:
		match option:
			ALL:
				return "Shows all animations."
			MOST:
				return "Shows all animations except against trivial enemies."
			SOME:
				return "Shows only boss animations."
			FEW:
				return "Shows only important boss animations."
		push_warning(get_error_message())
		return get_error_message()


## @experimental
## A [StringNameOption] for game speed.
class GameSpeedOption:
	extends StringNameOption

	## @experimental
	## Currently does nothing
	const NORMAL: StringName = &"normal"
	## @experimental
	## Currently does nothing
	const MAX: StringName = &"max"

	func _init() -> void:
		_name = &"game_speed"
		_default = NORMAL
		_settings = [NORMAL, MAX]
		_category = &"options"
		_description = "Set unit movement speed."
		super()


## @experimental
## A [StringNameOption] for text speed.
class TextSpeedOption:
	extends StringNameOption

	## @experimental
	## Currently does nothing
	const SLOW: StringName = &"slow"
	## @experimental
	## Currently does nothing
	const MEDIUM: StringName = &"medium"
	## @experimental
	## Currently does nothing
	const FAST: StringName = &"fast"
	## @experimental
	## Currently does nothing
	const MAX: StringName = &"max"

	func _init() -> void:
		_name = &"text_speed"
		_default = MEDIUM
		_settings = [SLOW, MEDIUM, FAST, MAX]
		_category = &"options"
		_description = "Set message speed."
		super()


## @experimental
## A [StringNameOption] for the unit panel.
class UnitPanelOption:
	extends StringNameOption

	## @experimental
	## Currently does nothing
	const PANEL: StringName = &"panel"
	## @experimental
	## Currently does nothing
	const BUBBLE: StringName = &"bubble"
	## @experimental
	## Currently does nothing
	const OFF: StringName = &"off"

	func _init() -> void:
		_name = &"unit_panel"
		_default = PANEL
		_settings = [PANEL, BUBBLE, OFF]
		_category = &"options"
		super()

	func get_description(option: StringName) -> String:
		match option:
			PANEL:
				return "Shows normal unit window."
			BUBBLE:
				return "Show unit window with tail."
			OFF:
				return "Turn unit window off."
		push_warning(get_error_message())
		return get_error_message()


## @experimental
## A [StringNameOption] for the combat panel.
class CombatPanelOption:
	extends StringNameOption

	## @experimental
	## Currently does nothing
	const STRATEGIC: StringName = &"strategic"
	## @experimental
	## Currently does nothing
	const DETAILED: StringName = &"detailed"
	## @experimental
	## Currently does nothing
	const OFF: StringName = &"off"

	func _init() -> void:
		_name = &"combat_panel"
		_default = STRATEGIC
		_settings = [STRATEGIC, DETAILED, OFF]
		_category = &"options"
		super()

	func get_description(option: StringName) -> String:
		match option:
			STRATEGIC:
				return "Shows standard Combat Info window."
			DETAILED:
				return "Shows detailed Combat Info window."
			OFF:
				return "Turn Combat Info window off."
		push_warning(get_error_message())
		return get_error_message()
