## A [Config] that stores options
extends Config

const ANIMATIONS: StringName = &"animations"
const GAME_SPEED: StringName = &"game_speed"
const TEXT_SPEED: StringName = &"text_speed"
const TERRAIN: StringName = &"terrain"
const UNIT_PANEL: StringName = &"unit_panel"
const COMBAT_PANEL: StringName = &"combat_panel"


func _init() -> void:
	_config = {
		ANIMATIONS: &"map",
		GAME_SPEED: &"normal",
		TEXT_SPEED: &"medium",
		TERRAIN: true,
		UNIT_PANEL: &"panel",
		COMBAT_PANEL: &"strategic",
	}
	_category = "Options"
	super()
