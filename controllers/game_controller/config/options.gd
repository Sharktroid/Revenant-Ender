## A [Node] that stores options
extends Node

#gdlint: disable = class-variable-name
# Controls what animations play
## @experimental Currently does nothing
var ANIMATIONS := AnimationsOption.new()
## Controls how fast the units move.
var GAME_SPEED := GameSpeedOption.new()
## Controls how fast the text scrolls.
var TEXT_SPEED := TextSpeedOption.new()
## @experimental Currently does nothing.
var TERRAIN := BooleanOption.new(&"terrain", &"main", true, "Set Terrain window display.")
## @experimental Currently does nothing.
var UNIT_PANEL := UnitPanelOption.new()
## Changes the information displayed on the Combat Panel.
var COMBAT_PANEL := CombatPanelOption.new()
## Causes the cursor to go back to the main hero upon.
var SMART_CURSOR := BooleanOption.new(
	&"smart_cursor", &"main", false, "Set cursor to start on main hero."
)
## Causes the cursor to go back to the deselected unit.
var CURSOR_RETURN := BooleanOption.new(
	&"cursor_return", &"main", false, "Set cursor to return to unit's position upon deselect."
)
## @experimental Currently does nothing.
var AUTOEND_TURNS := BooleanOption.new(
	&"autoend_turns", &"main", true, "Set turn to end automatically."
)
## Changes the volume of the music
var MUSIC := FloatOption.new(&"music_volume", &"main", 1.0, 0.0, 1.0, "Set music volume.")
## Changes the volume of sound effects.
var SOUND_EFFECTS := FloatOption.new(
	&"sound_effect_volume", &"main", 1.0, 0.0, 1.0, "Set sound effect volume."
)
## @experimental Currently does nothing.
var UNIT_PALETTE := BooleanOption.new(
	&"unit_palette", &"main", true, "Sets allies personal colors."
)
## Whether the debug menus are enabled.
## This is hidden for end users; needs to be manually enabled in the config.cfg file.
var DEBUG_ENABLED := BooleanOption.new(
	&"debug_enabled", &"debug", false, "Whether the debug menu is shown"
)
## Whether units are unable to move after movement.
var UNIT_WAIT := BooleanOption.new(
	&"unit_wait", &"debug", true, "Whether units are unable to move after movement"
)
## Whether map borders are displayed
var DISPLAY_MAP_BORDERS := BooleanOption.new(
	&"display_map_borders", &"debug", false, "Whether map borders are displayed"
)
## Whether a terrain overlay is rendered
var DISPLAY_MAP_TERRAIN := BooleanOption.new(
	&"display_map_terrain", &"debug", false, "Whether a terrain overlay is rendered"
)
## Whether a box representing the cursor's position is rendered
var DISPLAY_MAP_CURSOR := BooleanOption.new(
	&"display_map_cursor",
	&"debug",
	false,
	"Whether a box representing the cursor's position is rendered"
)
## Whether the input receiver is printed in the standard output
var PRINT_INPUT_RECEIVER := BooleanOption.new(
	&"print_input_receiver",
	&"debug",
	false,
	"Whether the input receiver is printed in the standard output"
)
## Whether the frame rate is displayed
var SHOW_FPS := BooleanOption.new(
	&"show_fps", &"debug", false, "Whether the frame rate is displayed"
)
#gdlint: enable = class-variable-name


## Gets the full list of the [ConfigOption]s in use.
func get_options() -> Dictionary[StringName, Array]:
	var options: Array[ConfigOption] = [
		ANIMATIONS,
		GAME_SPEED,
		TEXT_SPEED,
		TERRAIN,
		UNIT_PANEL,
		COMBAT_PANEL,
		SMART_CURSOR,
		CURSOR_RETURN,
		AUTOEND_TURNS,
		MUSIC,
		SOUND_EFFECTS,
		UNIT_PALETTE,
		UNIT_WAIT,
		DISPLAY_MAP_BORDERS,
		DISPLAY_MAP_TERRAIN,
		DISPLAY_MAP_CURSOR,
		PRINT_INPUT_RECEIVER,
		SHOW_FPS,
	]
	var dictionary: Dictionary[StringName, Array] = {}
	for option: ConfigOption in options:
		(dictionary.get_or_add(option.get_category(), []) as Array).append(option)
	return dictionary


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
		_category = &"main"
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
	## Sets unit speed to 8 tiles/second.
	const SLOW: StringName = &"slow"
	## @experimental
	## Sets unit speed to 16 tiles/second.
	const NORMAL: StringName = &"normal"
	## @experimental
	## Sets unit speed to 80 tiles/second.
	const FAST: StringName = &"fast"
	## @experimental
	## Sets unit speed to instantaneous.
	const MAX: StringName = &"max"

	func _init() -> void:
		_name = &"game_speed"
		_default = NORMAL
		_settings = [SLOW, NORMAL, FAST, MAX]
		_category = &"main"
		_description = "Set unit movement speed."
		super()


## @experimental
## A [StringNameOption] for text speed.
class TextSpeedOption:
	extends StringNameOption

	## @experimental
	## Sets the text speed to 75 characters/second.
	const SLOW: StringName = &"slow"
	## @experimental
	## Sets the text speed to 150 characters/second.
	const MEDIUM: StringName = &"medium"
	## @experimental
	## Sets the text speed to 300 characters/second.
	const FAST: StringName = &"fast"
	## @experimental
	## Sets the text speed to print as many characters as possible per second.
	const MAX: StringName = &"max"

	func _init() -> void:
		_name = &"text_speed"
		_default = MEDIUM
		_settings = [SLOW, MEDIUM, FAST, MAX]
		_category = &"main"
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
		_category = &"main"
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

	## Displays the strategic/simplified combat panel.
	const STRATEGIC: StringName = &"strategic"

	## Displays the detailed combat panel
	const DETAILED: StringName = &"detailed"

	## Hides the combat panel. Does not hide the weapon selection panel.
	const OFF: StringName = &"off"

	func _init() -> void:
		_name = &"combat_panel"
		_default = STRATEGIC
		_settings = [STRATEGIC, DETAILED, OFF]
		_category = &"main"
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
