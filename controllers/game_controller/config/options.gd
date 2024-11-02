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
var TERRAIN := BooleanOption.new(&"terrain", &"options", true)
## @experimental Currently does nothing.
var UNIT_PANEL := UnitPanelOption.new()
## @experimental Currently does nothing.
var COMBAT_PANEL := CombatPanelOption.new()
## @experimental Currently does nothing.
var AUTOCURSOR := BooleanOption.new(&"autocursor", &"options", true)
## @experimental Currently does nothing.
var AUTOEND_TURNS := BooleanOption.new(&"autoend_turns", &"options", true)
## @experimental Currently does nothing.
var MUSIC := BooleanOption.new(&"music", &"options", true)
## @experimental Currently does nothing.
var SOUND_EFFECTS := SoundEffectsOption.new()
## @experimental Currently does nothing.
var UNIT_PALETTE := BooleanOption.new(&"unit_palette", &"options", true)
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


## @experimental
## A [StringNameOption] for Sound Effect volume.
class SoundEffectsOption:
	extends StringNameOption

	## @experimental
	## Currently does nothing
	const HIGH: StringName = &"high"
	## @experimental
	const MEDIUM: StringName = &"medium"
	## @experimental
	## Currently does nothing
	const LOW: StringName = &"low"
	## @experimental
	## Currently does nothing
	const OFF: StringName = &"off"

	func _init() -> void:
		_name = &"sound_effects"
		_default = HIGH
		_settings = [HIGH, MEDIUM, LOW, OFF]
		_category = &"options"
		super()
